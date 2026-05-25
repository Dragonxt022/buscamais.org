import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "grid", "preview", "placeholder", "sgidField", "searchInput",
                    "uploadLabel", "uploadIcon", "uploadSpinner", "uploadText", "uploadStatus"]
  static values  = { url: String }

  connect() {
    this._loaded = false
  }

  open(event) {
    event.preventDefault()
    this.modalTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
    if (!this._loaded) this._load()
  }

  close() {
    this.modalTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }

  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) this.close()
  }

  search() {
    clearTimeout(this._searchTimer)
    this._searchTimer = setTimeout(() => this._load(), 350)
  }

  async _load() {
    const q   = this.hasSearchInputTarget ? this.searchInputTarget.value : ""
    const url = `${this.urlValue}?apenas_imagens=1&q=${encodeURIComponent(q)}`
    this.gridTarget.innerHTML = this._loadingHTML()
    try {
      const resp = await fetch(url, { headers: { Accept: "application/json" } })
      const data = await resp.json()
      this.gridTarget.innerHTML = this._renderGrid(data.midias || [])
      this._loaded = true
    } catch {
      this.gridTarget.innerHTML = '<p class="col-span-full text-center text-red-400 text-sm py-8">Erro ao carregar galeria.</p>'
    }
  }

  _loadingHTML() {
    return '<div class="col-span-full flex justify-center py-10"><svg class="animate-spin h-8 w-8 text-blue-500" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8z"/></svg></div>'
  }

  _renderGrid(midias) {
    if (!midias.length) {
      return '<p class="col-span-full text-center text-gray-400 text-sm py-10">Nenhuma imagem na galeria. Faça o upload acima.</p>'
    }
    return midias.map(m => `
      <button type="button"
              class="group relative aspect-square overflow-hidden rounded-lg border-2 border-transparent hover:border-blue-500 focus:outline-none focus:border-blue-500 transition-all bg-gray-100"
              data-action="click->media-gallery#select"
              data-signed-id="${m.signed_id}"
              data-url="${m.url}"
              title="${m.nome}">
        <img src="${m.url}" alt="${m.nome}" class="w-full h-full object-cover"
             onerror="this.src='data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 24 24%22%3E%3Crect fill=%22%23f3f4f6%22 width=%2224%22 height=%2224%22/%3E%3Cpath fill=%22%23d1d5db%22 d=%22M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z%22/%3E%3C/svg%3E'; this.onerror=null">
        <div class="absolute inset-0 bg-black/0 group-hover:bg-black/30 transition-colors flex items-end">
          <span class="w-full text-white text-xs truncate px-1.5 py-1 bg-gradient-to-t from-black/70 to-transparent opacity-0 group-hover:opacity-100 transition-opacity">${m.nome}</span>
        </div>
      </button>
    `).join("")
  }

  select(event) {
    const { signedId, url } = event.currentTarget.dataset

    if (this.hasSgidFieldTarget)  this.sgidFieldTarget.value = signedId

    if (this.hasPreviewTarget) {
      this.previewTarget.src = url
      this.previewTarget.classList.remove("hidden")
    }
    if (this.hasPlaceholderTarget) this.placeholderTarget.classList.add("hidden")

    this.close()
  }

  async upload(event) {
    const files = Array.from(event.target.files)
    if (!files.length) return

    this._setUploading(true)
    this._setStatus(`Enviando ${files.length > 1 ? files.length + " arquivos" : "arquivo"}...`, "blue")

    const csrf = document.querySelector('meta[name="csrf-token"]')
    let successCount = 0
    let errorCount   = 0

    for (const file of files) {
      const form = new FormData()
      form.append("media_file[arquivo]", file)
      try {
        const resp = await fetch(this.urlValue, {
          method: "POST",
          headers: { "X-CSRF-Token": csrf?.content, Accept: "application/json" },
          body: form
        })
        if (resp.ok) { successCount++ } else { errorCount++ }
      } catch { errorCount++ }
    }

    this._setUploading(false)
    if (errorCount === 0) {
      this._setStatus(`${successCount} ${successCount === 1 ? "arquivo enviado" : "arquivos enviados"}!`, "green")
    } else {
      this._setStatus(`${successCount} enviados, ${errorCount} com erro.`, "red")
    }

    this._loaded = false
    this._load()
    event.target.value = ""
  }

  _setUploading(uploading) {
    if (this.hasUploadLabelTarget) {
      this.uploadLabelTarget.style.pointerEvents = uploading ? "none" : ""
      this.uploadLabelTarget.style.opacity       = uploading ? "0.85" : ""
    }
    if (this.hasUploadIconTarget)    this.uploadIconTarget.classList.toggle("hidden", uploading)
    if (this.hasUploadSpinnerTarget) this.uploadSpinnerTarget.classList.toggle("hidden", !uploading)
    if (this.hasUploadTextTarget)    this.uploadTextTarget.textContent = uploading ? "Enviando..." : "Fazer Upload"
    if (this.hasUploadStatusTarget)  {
      if (!uploading) return
      this.uploadStatusTarget.classList.remove("hidden", "text-green-600", "text-red-500")
      this.uploadStatusTarget.classList.add("text-blue-600")
    }
  }

  _setStatus(text, color) {
    if (!this.hasUploadStatusTarget) return
    const map = { blue: "text-blue-600", green: "text-green-600", red: "text-red-500" }
    this.uploadStatusTarget.classList.remove("hidden", "text-blue-600", "text-green-600", "text-red-500")
    this.uploadStatusTarget.classList.add(map[color] || "text-blue-600")
    this.uploadStatusTarget.textContent = text
  }
}
