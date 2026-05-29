import { Controller } from "@hotwired/stimulus"

const PLACEHOLDER_IMG = "data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 24 24%22%3E%3Crect fill=%22%23f3f4f6%22 width=%2224%22 height=%2224%22/%3E%3Cpath fill=%22%23d1d5db%22 d=%22M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z%22/%3E%3C/svg%3E"

export default class extends Controller {
  static targets = ["editor", "input", "panel", "grid", "spinner", "search", "uploadInput", "uploadStatus"]
  static values  = { url: String }

  connect() {
    const Quill = window.Quill
    if (!Quill) { console.error("Quill não carregado"); return }

    this._quill = new Quill(this.editorTarget, {
      theme: "snow",
      placeholder: "Escreva o conteúdo da matéria aqui. Use a barra de ferramentas para formatar texto, adicionar links e inserir imagens...",
      modules: {
        toolbar: {
          container: [
            [{ header: [1, 2, 3, false] }],
            ["bold", "italic", "underline", "strike"],
            ["blockquote", "code-block"],
            [{ list: "ordered" }, { list: "bullet" }],
            [{ align: [] }],
            ["link", "image"],
            ["clean"]
          ],
          handlers: { image: () => this.open() }
        },
        clipboard: { matchVisual: false }
      }
    })

    const existing = this.inputTarget.value.trim()
    if (existing) this._quill.clipboard.dangerouslyPasteHTML(existing)

    this._quill.on("text-change", () => {
      this.inputTarget.value = this._quill.root.innerHTML
    })
  }

  disconnect() {
    this._quill = null
  }

  // ── Gallery panel ─────────────────────────────────────────────────────────────
  open() {
    this.panelTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
    this._load()
  }

  close() {
    this.panelTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }

  closeBackdrop(event) {
    if (event.target === this.panelTarget) this.close()
  }

  search() {
    clearTimeout(this._searchTimer)
    this._searchTimer = setTimeout(() => this._load(), 300)
  }

  // ── Load gallery ──────────────────────────────────────────────────────────────
  async _load() {
    this.spinnerTarget.classList.remove("hidden")
    this.gridTarget.innerHTML = ""
    const q   = this.hasSearchTarget ? this.searchTarget.value : ""
    const url = `${this.urlValue}?apenas_imagens=1${q ? "&q=" + encodeURIComponent(q) : ""}`
    try {
      const resp = await fetch(url, { headers: { Accept: "application/json" } })
      const data = await resp.json()
      this._render(data.midias || [])
    } catch {
      this.gridTarget.innerHTML = '<p class="col-span-4 text-center text-sm text-red-500 py-6">Erro ao carregar galeria.</p>'
    } finally {
      this.spinnerTarget.classList.add("hidden")
    }
  }

  _render(midias) {
    if (!midias.length) {
      this.gridTarget.innerHTML = '<p class="col-span-4 text-center text-sm text-gray-400 py-8">Nenhuma imagem encontrada. Faça upload acima.</p>'
      return
    }
    this.gridTarget.innerHTML = midias.map(m => `
      <button type="button"
              class="group relative aspect-square overflow-hidden rounded-xl border-2 border-transparent hover:border-blue-500 focus:outline-none focus:border-blue-500 transition-all bg-gray-100"
              data-action="click->rich-editor#insert"
              data-url="${escHtml(m.url)}"
              data-nome="${escHtml(m.nome)}">
        <img src="${escHtml(m.url)}" alt="${escHtml(m.nome)}"
             class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-200"
             onerror="this.src='${PLACEHOLDER_IMG}';this.onerror=null">
        <div class="absolute inset-0 bg-black/0 group-hover:bg-black/20 transition-colors"></div>
        <span class="absolute bottom-0 left-0 right-0 text-white text-[10px] truncate px-1.5 py-1 bg-gradient-to-t from-black/70 to-transparent opacity-0 group-hover:opacity-100 transition-opacity">${escHtml(m.nome)}</span>
      </button>
    `).join("")
  }

  // ── Insert image from gallery into Quill ──────────────────────────────────────
  insert(event) {
    if (!this._quill) return
    const { url, nome } = event.currentTarget.dataset
    const range = this._quill.getSelection(true)
    this._quill.insertEmbed(range.index, "image", url, "user")
    this._quill.setSelection(range.index + 1, "silent")
    this.close()
  }

  // ── Upload button inside gallery panel ────────────────────────────────────────
  async upload(event) {
    const files = Array.from(event.target.files)
    if (!files.length) return
    this._setStatus("Enviando...", "blue")
    let ok = 0, err = 0
    for (const file of files) {
      try { await this._uploadFile(file); ok++ } catch { err++ }
    }
    event.target.value = ""
    this._setStatus(
      err === 0
        ? `${ok} ${ok === 1 ? "imagem enviada" : "imagens enviadas"}!`
        : `${ok} enviadas, ${err} com erro`,
      err === 0 ? "green" : "red"
    )
    this._load()
    setTimeout(() => this._clearStatus(), 3000)
  }

  // ── Core upload helper ────────────────────────────────────────────────────────
  async _uploadFile(file) {
    const csrf = document.querySelector('meta[name="csrf-token"]')
    const form = new FormData()
    form.append("media_file[arquivo]", file)
    const resp = await fetch(this.urlValue, {
      method:  "POST",
      headers: { "X-CSRF-Token": csrf?.content, Accept: "application/json" },
      body:    form
    })
    if (!resp.ok) throw new Error("upload failed")
    return resp.json()
  }

  _setStatus(text, color) {
    if (!this.hasUploadStatusTarget) return
    const cls = { blue: "text-blue-600", green: "text-green-600", red: "text-red-500" }
    this.uploadStatusTarget.className = `text-xs font-medium ${cls[color] || "text-blue-600"}`
    this.uploadStatusTarget.textContent = text
    this.uploadStatusTarget.classList.remove("hidden")
  }

  _clearStatus() {
    this.uploadStatusTarget?.classList.add("hidden")
  }
}

function escHtml(str) {
  return String(str ?? "").replace(/[&<>"']/g, c =>
    ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]))
}
