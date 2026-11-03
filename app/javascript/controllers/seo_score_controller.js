import { Controller } from "@hotwired/stimulus"

// Analisador de SEO ao vivo, no estilo Yoast: roda inteiramente no navegador,
// sem chamada ao servidor, recalculando a cada mudança nos campos do formulário.
export default class extends Controller {
  static targets = [
    "titulo", "resumo", "conteudo", "palavraChave",
    "legenda", "imagemSgid", "imagemPreview", "categoria", "tags",
    "score", "scoreLabel", "lista"
  ]

  connect() {
    this.analisar()
  }

  analisar() {
    const titulo   = this.hasTituloTarget       ? this.tituloTarget.value : ""
    const resumo   = this.hasResumoTarget       ? this.resumoTarget.value : ""
    const html     = this.hasConteudoTarget     ? this.conteudoTarget.value : ""
    const kw       = this.hasPalavraChaveTarget ? this.palavraChaveTarget.value.trim().toLowerCase() : ""
    const legenda  = this.hasLegendaTarget      ? this.legendaTarget.value : ""
    const temImagem = this._temImagem()
    const categoriaOk = this.hasCategoriaTarget ? this.categoriaTarget.value.trim().length > 0 : true
    const tags     = this.hasTagsTarget         ? this.tagsTarget.value : ""

    const texto = this._textoPuro(html)
    const checks = this._checks({ titulo, resumo, texto, html, kw, legenda, temImagem, categoriaOk, tags })

    this._render(checks)
  }

  // Verdadeiro se já existe imagem de capa (anexada previamente) OU se uma
  // nova foi selecionada agora na galeria — os dois casos são visíveis no
  // preview do card "Imagem de Capa", que é a fonte confiável aqui (o campo
  // oculto `imagem_capa_sgid` só é preenchido quando uma NOVA imagem é
  // escolhida, ficando vazio para uma imagem já salva anteriormente).
  _temImagem() {
    if (this.hasImagemPreviewTarget && !this.imagemPreviewTarget.classList.contains("hidden")) return true
    if (this.hasImagemSgidTarget && this.imagemSgidTarget.value.trim().length > 0) return true
    return false
  }

  _textoPuro(html) {
    const div = document.createElement("div")
    div.innerHTML = html
    return (div.textContent || "").replace(/\s+/g, " ").trim()
  }

  _checks({ titulo, resumo, texto, html, kw, legenda, temImagem, categoriaOk, tags }) {
    const checks = []

    // ── Título ──────────────────────────────────────────────────────────
    const tLen = titulo.trim().length
    if (tLen === 0) {
      checks.push(["bad", "Adicione um título."])
    } else if (tLen < 40) {
      checks.push(["ok", `Título com ${tLen} caracteres — pode ser um pouco mais longo (ideal 40–60).`])
    } else if (tLen > 60) {
      checks.push(["ok", `Título com ${tLen} caracteres — pode ser cortado nos resultados de busca (ideal até 60).`])
    } else {
      checks.push(["good", `Bom tamanho de título (${tLen} caracteres).`])
    }

    if (kw) {
      const idx = titulo.toLowerCase().indexOf(kw)
      if (idx === -1) checks.push(["bad", "A palavra-chave de foco não aparece no título."])
      else if (idx <= 10) checks.push(["good", "A palavra-chave de foco aparece no início do título."])
      else checks.push(["good", "A palavra-chave de foco aparece no título."])
    }

    // ── Resumo / meta description ─────────────────────────────────────
    const rLen = resumo.trim().length
    if (rLen === 0) {
      checks.push(["bad", "Adicione um resumo — ele vira a meta description da notícia."])
    } else if (rLen < 120) {
      checks.push(["ok", `Resumo com ${rLen} caracteres — pode ser mais longo (ideal 120–156).`])
    } else if (rLen > 156) {
      checks.push(["ok", `Resumo com ${rLen} caracteres — pode ser cortado nos resultados de busca (ideal até 156).`])
    } else {
      checks.push(["good", `Bom tamanho de resumo (${rLen} caracteres).`])
    }

    if (kw && rLen > 0) {
      checks.push(resumo.toLowerCase().includes(kw)
        ? ["good", "A palavra-chave de foco aparece no resumo."]
        : ["ok", "A palavra-chave de foco não aparece no resumo."])
    }

    // ── Conteúdo ────────────────────────────────────────────────────────
    const palavras = texto.split(/\s+/).filter(Boolean)
    const total = palavras.length
    if (total < 200) {
      checks.push(["bad", `Conteúdo com ${total} palavras — abaixo do mínimo recomendado (300).`])
    } else if (total < 300) {
      checks.push(["ok", `Conteúdo com ${total} palavras — perto do mínimo recomendado (300).`])
    } else {
      checks.push(["good", `Bom tamanho de conteúdo (${total} palavras).`])
    }

    if (kw && total > 0) {
      const textoLower = texto.toLowerCase()
      const ocorrencias = textoLower.split(kw).length - 1
      const densidade = (ocorrencias / total) * 100
      if (ocorrencias === 0) {
        checks.push(["bad", "A palavra-chave de foco não aparece no conteúdo."])
      } else if (densidade > 3) {
        checks.push(["bad", `Densidade de palavra-chave alta (${densidade.toFixed(1)}%) — parece repetição forçada.`])
      } else if (densidade < 0.3) {
        checks.push(["ok", `Densidade de palavra-chave baixa (${densidade.toFixed(1)}%) — considere usá-la mais vezes.`])
      } else {
        checks.push(["good", `Boa densidade de palavra-chave (${densidade.toFixed(1)}%).`])
      }

      const inicio = palavras.slice(0, 100).join(" ").toLowerCase()
      checks.push(inicio.includes(kw)
        ? ["good", "A palavra-chave de foco aparece logo no início do texto."]
        : ["ok", "A palavra-chave de foco não aparece nas primeiras ~100 palavras."])
    }

    const temSubtitulo = /<h[23][ >]/i.test(html)
    checks.push(temSubtitulo
      ? ["good", "O texto usa subtítulos, o que ajuda a leitura e o SEO."]
      : ["ok", "Considere usar subtítulos (Título 2/3) para organizar o texto."])

    const temLink = /<a\s+[^>]*href=/i.test(html)
    checks.push(temLink
      ? ["good", "O conteúdo tem pelo menos um link."]
      : ["ok", "Considere linkar para uma notícia relacionada ou uma fonte oficial."])

    // ── Imagem ──────────────────────────────────────────────────────────
    checks.push(temImagem
      ? ["good", "A matéria tem imagem de capa."]
      : ["bad", "Adicione uma imagem de capa."])

    if (temImagem) {
      checks.push(legenda.trim().length > 0
        ? ["good", "A imagem tem legenda."]
        : ["ok", "Considere adicionar uma legenda para a imagem."])
    }

    // ── Categoria e tags ────────────────────────────────────────────────
    checks.push(categoriaOk
      ? ["good", "Categoria principal selecionada."]
      : ["bad", "Selecione uma categoria principal."])

    checks.push(tags.trim().length > 0
      ? ["good", "A matéria tem tags."]
      : ["ok", "Considere adicionar algumas tags relevantes."])

    return checks
  }

  _render(checks) {
    const pesos = { good: 1, ok: 0.5, bad: 0 }
    const pontuacao = checks.length
      ? Math.round((checks.reduce((soma, [status]) => soma + pesos[status], 0) / checks.length) * 100)
      : 0

    let cor = "red", label = "Precisa melhorar"
    if (pontuacao >= 80) { cor = "green"; label = "Bom" }
    else if (pontuacao >= 50) { cor = "amber"; label = "Razoável" }

    const cores = {
      red:   { bg: "bg-red-50",   text: "text-red-600",   ring: "ring-red-200" },
      amber: { bg: "bg-amber-50", text: "text-amber-600", ring: "ring-amber-200" },
      green: { bg: "bg-green-50", text: "text-green-600", ring: "ring-green-200" }
    }[cor]

    if (this.hasScoreTarget) {
      this.scoreTarget.textContent = pontuacao
      this.scoreTarget.className = `w-14 h-14 rounded-full flex items-center justify-center text-lg font-black shrink-0 ring-4 ${cores.bg} ${cores.text} ${cores.ring}`
    }
    if (this.hasScoreLabelTarget) {
      this.scoreLabelTarget.textContent = label
      this.scoreLabelTarget.className = `text-sm font-semibold ${cores.text}`
    }

    if (this.hasListaTarget) {
      const iconePorStatus = {
        good: '<svg class="w-3.5 h-3.5 text-green-600 shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/></svg>',
        ok:   '<svg class="w-3.5 h-3.5 text-amber-500 shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M12 9v4m0 4h.01M10.29 3.86l-8.18 14.14A1.5 1.5 0 003.4 20.4h17.2a1.5 1.5 0 001.29-2.4L13.71 3.86a1.5 1.5 0 00-2.42 0z"/></svg>',
        bad:  '<svg class="w-3.5 h-3.5 text-red-500 shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/></svg>'
      }
      this.listaTarget.innerHTML = checks
        .map(([status, texto]) => `
          <li class="flex items-start gap-2 text-xs text-gray-600 leading-snug">
            ${iconePorStatus[status]}
            <span>${_escHtml(texto)}</span>
          </li>
        `).join("")
    }
  }
}

function _escHtml(str) {
  return String(str ?? "").replace(/[&<>"']/g, c =>
    ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]))
}
