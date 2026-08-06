import { Controller } from "@hotwired/stimulus"

const PLACEHOLDER_IMG = "data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 24 24%22%3E%3Crect fill=%22%23f3f4f6%22 width=%2224%22 height=%2224%22/%3E%3Cpath fill=%22%23d1d5db%22 d=%22M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z%22/%3E%3C/svg%3E"

// Path data — Lucide (lucide.dev, ISC license), mesma fonte usada em IconHelper.
const TOOL_ICONS = {
  "heading-1":     '<path d="M4 12h8"/><path d="M4 18V6"/><path d="M12 18V6"/><path d="m17 12 3-2v8"/>',
  "heading-2":     '<path d="M4 12h8"/><path d="M4 18V6"/><path d="M12 18V6"/><path d="M21 18h-4c0-4 4-3 4-6 0-1.5-2-2.5-4-1"/>',
  "heading-3":     '<path d="M4 12h8"/><path d="M4 18V6"/><path d="M12 18V6"/><path d="M17.5 10.5c1.7-1 3.5 0 3.5 1.5a2 2 0 0 1-2 2"/><path d="M17 17.5c2 1.5 4 .3 4-1.5a2 2 0 0 0-2-2"/>',
  "pilcrow":       '<path d="M13 4v16"/><path d="M17 4v16"/><path d="M19 4H9.5a4.5 4.5 0 0 0 0 9H13"/>',
  "bold":          '<path d="M6 12h9a4 4 0 0 1 0 8H7a1 1 0 0 1-1-1V5a1 1 0 0 1 1-1h7a4 4 0 0 1 0 8"/>',
  "italic":        '<line x1="19" x2="10" y1="4" y2="4"/><line x1="14" x2="5" y1="20" y2="20"/><line x1="15" x2="9" y1="4" y2="20"/>',
  "underline":     '<path d="M6 4v6a6 6 0 0 0 12 0V4"/><line x1="4" x2="20" y1="20" y2="20"/>',
  "strikethrough": '<path d="M16 4H9a3 3 0 0 0-2.83 4"/><path d="M14 12a4 4 0 0 1 0 8H6"/><line x1="4" x2="20" y1="12" y2="12"/>',
  "quote":         '<path d="M16 3a2 2 0 0 0-2 2v6a2 2 0 0 0 2 2 1 1 0 0 1 1 1v1a2 2 0 0 1-2 2 1 1 0 0 0-1 1v2a1 1 0 0 0 1 1 6 6 0 0 0 6-6V5a2 2 0 0 0-2-2z"/><path d="M5 3a2 2 0 0 0-2 2v6a2 2 0 0 0 2 2 1 1 0 0 1 1 1v1a2 2 0 0 1-2 2 1 1 0 0 0-1 1v2a1 1 0 0 0 1 1 6 6 0 0 0 6-6V5a2 2 0 0 0-2-2z"/>',
  "code":          '<path d="m16 18 6-6-6-6"/><path d="m8 6-6 6 6 6"/>',
  "list-ordered":  '<path d="M11 5h10"/><path d="M11 12h10"/><path d="M11 19h10"/><path d="M4 4h1v5"/><path d="M4 9h2"/><path d="M6.5 20H3.4c0-1 2.6-1.925 2.6-3.5a1.5 1.5 0 0 0-2.6-1.02"/>',
  "list":          '<path d="M3 5h.01"/><path d="M3 12h.01"/><path d="M3 19h.01"/><path d="M8 5h13"/><path d="M8 12h13"/><path d="M8 19h13"/>',
  "align-left":    '<path d="M21 5H3"/><path d="M15 12H3"/><path d="M17 19H3"/>',
  "align-center":  '<path d="M21 5H3"/><path d="M17 12H7"/><path d="M19 19H5"/>',
  "align-right":   '<path d="M21 5H3"/><path d="M21 12H9"/><path d="M21 19H7"/>',
  "link":          '<path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/>',
  "image":         '<rect width="18" height="18" x="3" y="3" rx="2" ry="2"/><circle cx="9" cy="9" r="2"/><path d="m21 15-3.086-3.086a2 2 0 0 0-2.828 0L6 21"/>',
  "eraser":        '<path d="M21 21H8a2 2 0 0 1-1.42-.587l-3.994-3.999a2 2 0 0 1 0-2.828l10-10a2 2 0 0 1 2.829 0l5.999 6a2 2 0 0 1 0 2.828L12.834 21"/><path d="m5.082 11.09 8.828 8.828"/>'
}

function iconSvg(name) {
  return `<svg class="w-4 h-4 shrink-0 text-gray-500" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" viewBox="0 0 24 24">${TOOL_ICONS[name] || ""}</svg>`
}

// Espelha os grupos da toolbar do Quill (ver modules.toolbar abaixo), com ícone + nome.
const TOOLBAR_ITEMS = [
  { label: "Título 1",              icon: "heading-1",     type: "header", value: 1 },
  { label: "Título 2",              icon: "heading-2",     type: "header", value: 2 },
  { label: "Título 3",              icon: "heading-3",     type: "header", value: 3 },
  { label: "Normal",                icon: "pilcrow",       type: "header", value: false },
  { divider: true },
  { label: "Negrito",               icon: "bold",          type: "bold" },
  { label: "Itálico",               icon: "italic",        type: "italic" },
  { label: "Sublinhado",            icon: "underline",     type: "underline" },
  { label: "Tachado",               icon: "strikethrough", type: "strike" },
  { divider: true },
  { label: "Citação",               icon: "quote",         type: "blockquote" },
  { label: "Bloco de código",       icon: "code",          type: "code-block" },
  { divider: true },
  { label: "Lista numerada",        icon: "list-ordered",  type: "list", value: "ordered" },
  { label: "Lista com marcadores",  icon: "list",          type: "list", value: "bullet" },
  { divider: true },
  { label: "Alinhar à esquerda",    icon: "align-left",    type: "align", value: false },
  { label: "Centralizar",           icon: "align-center",  type: "align", value: "center" },
  { label: "Alinhar à direita",     icon: "align-right",   type: "align", value: "right" },
  { divider: true },
  { label: "Link",                  icon: "link",  special: "link" },
  { label: "Imagem",                icon: "image", special: "image" },
  { divider: true },
  { label: "Limpar formatação",     icon: "eraser", special: "clean" }
]

const TOGGLE_TYPES = ["bold", "italic", "underline", "strike", "blockquote", "code-block"]

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
    this._closeContextMenu()
  }

  // ── Menu de contexto (botão direito) ──────────────────────────────────────────
  openContextMenu(event) {
    if (!this._quill) return
    event.preventDefault()

    // Captura a seleção antes que o clique no menu (fora do editor) tire o foco.
    this._savedRange = this._quill.getSelection(true)
    this._closeContextMenu()

    const menu = document.createElement("div")
    menu.className = "fixed z-[60] bg-white rounded-xl shadow-2xl border border-gray-200 py-1.5 text-sm"
    menu.style.minWidth = "220px"
    menu.style.maxHeight = "80vh"
    menu.style.overflowY = "auto"

    TOOLBAR_ITEMS.forEach(item => {
      if (item.divider) {
        const hr = document.createElement("div")
        hr.className = "my-1 border-t border-gray-100"
        menu.appendChild(hr)
        return
      }
      const btn = document.createElement("button")
      btn.type = "button"
      btn.className = "w-full flex items-center gap-2.5 px-3 py-1.5 text-left text-gray-700 hover:bg-gray-100 transition-colors"
      btn.innerHTML = `${iconSvg(item.icon)}<span>${item.label}</span>`
      btn.addEventListener("click", () => {
        this._applyItem(item)
        this._closeContextMenu()
      })
      menu.appendChild(btn)
    })

    document.body.appendChild(menu)
    this._menuEl = menu

    menu.style.left = `${event.clientX}px`
    menu.style.top  = `${event.clientY}px`

    const rect = menu.getBoundingClientRect()
    let left = event.clientX
    let top  = event.clientY
    if (rect.right  > window.innerWidth)  left -= (rect.right  - window.innerWidth  + 8)
    if (rect.bottom > window.innerHeight) top  -= (rect.bottom - window.innerHeight + 8)
    menu.style.left = `${Math.max(8, left)}px`
    menu.style.top  = `${Math.max(8, top)}px`

    this._outsideHandler = e => { if (!menu.contains(e.target)) this._closeContextMenu() }
    this._escHandler = e => { if (e.key === "Escape") this._closeContextMenu() }
    document.addEventListener("click", this._outsideHandler)
    document.addEventListener("keydown", this._escHandler)
  }

  _closeContextMenu() {
    if (this._menuEl) { this._menuEl.remove(); this._menuEl = null }
    if (this._outsideHandler) { document.removeEventListener("click", this._outsideHandler); this._outsideHandler = null }
    if (this._escHandler) { document.removeEventListener("keydown", this._escHandler); this._escHandler = null }
  }

  _applyItem(item) {
    if (!this._quill || !this._savedRange) return
    this._quill.setSelection(this._savedRange.index, this._savedRange.length, "silent")

    if (item.special === "image") { this.open(); return }

    if (item.special === "link") {
      const url = window.prompt("URL do link:", "https://")
      if (url) this._quill.format("link", url)
      return
    }

    if (item.special === "clean") {
      this._quill.removeFormat(this._savedRange.index, this._savedRange.length)
      return
    }

    const current = this._quill.getFormat()

    if (TOGGLE_TYPES.includes(item.type)) {
      this._quill.format(item.type, !current[item.type])
      return
    }

    // header / list / align — clicar na opção já ativa reverte para o padrão
    const value = current[item.type] === item.value ? false : item.value
    this._quill.format(item.type, value)
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
