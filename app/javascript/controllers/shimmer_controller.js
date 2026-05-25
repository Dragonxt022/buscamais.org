import { Controller } from "@hotwired/stimulus"

// Dois modos:
//   data-shimmer-mode-value="image" (padrão) — remove shimmer quando img carrega
//   data-shimmer-mode-value="table"          — overlay de loading durante navegação Turbo
export default class extends Controller {
  static values = { mode: { type: String, default: "image" } }

  connect() {
    if (this.modeValue === "table") {
      this._onFetch  = () => this.element.classList.add("table-loading")
      this._onRender = () => this.element.classList.remove("table-loading")
      document.addEventListener("turbo:before-fetch-request", this._onFetch)
      document.addEventListener("turbo:render",               this._onRender)
    } else {
      this._initImage()
    }
  }

  disconnect() {
    if (this._onFetch)  document.removeEventListener("turbo:before-fetch-request", this._onFetch)
    if (this._onRender) document.removeEventListener("turbo:render",               this._onRender)
  }

  // ── Imagem ────────────────────────────────────────────────────────────
  _initImage() {
    const img = this.element.tagName === "IMG"
      ? this.element
      : this.element.querySelector("img")
    if (!img) return

    if (img.complete && img.naturalWidth > 0) {
      this._reveal()
    } else {
      img.addEventListener("load",  () => this._reveal(), { once: true })
      img.addEventListener("error", () => this._reveal(), { once: true })
    }
  }

  _reveal() {
    // Remove a classe shimmer do wrapper e deixa a img visível
    const wrapper = this.modeValue === "image" ? this.element : null
    if (wrapper) {
      wrapper.classList.remove("shimmer")
      const img = wrapper.querySelector("img")
      if (img) img.style.opacity = "1"
    }
  }
}
