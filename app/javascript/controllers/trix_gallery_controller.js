import { Controller } from "@hotwired/stimulus"

const PLACEHOLDER = "data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 24 24%22%3E%3Crect fill=%22%23f3f4f6%22 width=%2224%22 height=%2224%22/%3E%3Cpath fill=%22%23d1d5db%22 d=%22M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z%22/%3E%3C/svg%3E"

export default class extends Controller {
  static targets = ["panel", "grid", "spinner", "search", "uploadInput", "uploadStatus"]
  static values  = { url: String }

  connect() {
    this._trix = this.element.querySelector("trix-editor")
    if (!this._trix) return

    // Register on the WRAPPER element (ancestor of trix-editor) with capture:true.
    // This fires during the capture phase — before any listener on the trix-editor
    // target itself — giving us guaranteed priority over ActionText's own handlers.
    this._boundOnAction     = this._onAction.bind(this)
    this._boundOnFileAccept = this._onFileAccept.bind(this)

    this.element.addEventListener("trix-action-invoke", this._boundOnAction,     { capture: true })
    this.element.addEventListener("trix-file-accept",   this._boundOnFileAccept, { capture: true })
  }

  disconnect() {
    this.element.removeEventListener("trix-action-invoke", this._boundOnAction,     { capture: true })
    this.element.removeEventListener("trix-file-accept",   this._boundOnFileAccept, { capture: true })
  }

  // ── Intercept paperclip button ──────────────────────────────────────────────
  _onAction(event) {
    if (event.actionName !== "x-attach") return
    event.preventDefault()
    event.stopImmediatePropagation()
    this.open()
  }

  // ── Intercept drag-drop / paste files → send to gallery ────────────────────
  _onFileAccept(event) {
    const file = event.file ?? event.detail?.file
    if (!file) return
    event.preventDefault()
    event.stopImmediatePropagation()
    this._uploadAndInsert(file)
  }

  // ── Gallery panel open / close ──────────────────────────────────────────────
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

  // ── Search ──────────────────────────────────────────────────────────────────
  search() {
    clearTimeout(this._searchTimer)
    this._searchTimer = setTimeout(() => this._load(), 300)
  }

  // ── Load gallery images via JSON ─────────────────────────────────────────────
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
              data-action="click->trix-gallery#insert"
              data-url="${m.url}"
              data-sgid="${m.sgid}"
              data-nome="${escapeHtml(m.nome)}"
              data-tipo="${m.tipo}">
        <img src="${m.url}" alt="${escapeHtml(m.nome)}"
             class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-200"
             onerror="this.src='${PLACEHOLDER}';this.onerror=null">
        <div class="absolute inset-0 bg-black/0 group-hover:bg-black/20 transition-colors"></div>
        <span class="absolute bottom-0 left-0 right-0 text-white text-[10px] truncate px-1.5 py-1 bg-gradient-to-t from-black/70 to-transparent opacity-0 group-hover:opacity-100 transition-opacity">${escapeHtml(m.nome)}</span>
      </button>
    `).join("")
  }

  // ── Insert selected gallery image into Trix ─────────────────────────────────
  insert(event) {
    if (!this._trix?.editor) return
    const { url, sgid, nome, tipo } = event.currentTarget.dataset
    const attachment = new Trix.Attachment({ sgid, url, contentType: tipo, filename: nome, previewable: true })
    this._trix.editor.insertAttachment(attachment)
    this._trix.editor.insertLineBreak()
    this.close()
  }

  // ── Upload button (inside gallery panel header) ─────────────────────────────
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
      err === 0 ? `${ok} ${ok === 1 ? "imagem enviada" : "imagens enviadas"}!` : `${ok} enviadas, ${err} com erro`,
      err === 0 ? "green" : "red"
    )
    this._load()
    setTimeout(() => this._clearStatus(), 3000)
  }

  // ── Upload a single file and insert it directly into Trix ───────────────────
  async _uploadAndInsert(file) {
    this._setStatus("Enviando...", "blue")
    try {
      const m = await this._uploadFile(file)
      if (this._trix?.editor) {
        const attachment = new Trix.Attachment({
          sgid: m.sgid, url: m.url, contentType: m.tipo, filename: m.nome, previewable: true
        })
        this._trix.editor.insertAttachment(attachment)
        this._trix.editor.insertLineBreak()
      }
      this._setStatus("Imagem adicionada!", "green")
    } catch {
      this._setStatus("Erro ao enviar.", "red")
    }
    setTimeout(() => this._clearStatus(), 3000)
  }

  // ── Core upload helper ───────────────────────────────────────────────────────
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

  // ── Status helpers ───────────────────────────────────────────────────────────
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

function escapeHtml(str) {
  return String(str).replace(/[&<>"']/g, c =>
    ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]))
}
