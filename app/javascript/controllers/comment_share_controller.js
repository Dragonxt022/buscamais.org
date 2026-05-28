import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]
  static values  = { url: String }

  toggle(event) {
    event.stopPropagation()
    const isOpen = !this.menuTarget.classList.contains("hidden")
    document.querySelectorAll("[data-comment-share-target='menu']").forEach(m => {
      m.classList.add("hidden")
    })
    if (!isOpen) this.menuTarget.classList.remove("hidden")
  }

  async copiar(event) {
    event.preventDefault()
    const url = this.urlValue || window.location.href
    try {
      await navigator.clipboard.writeText(url)
      const btn = event.currentTarget
      const orig = btn.textContent.trim()
      btn.textContent = "✓ Copiado!"
      setTimeout(() => { btn.textContent = orig; this.fechar() }, 1500)
    } catch {
      prompt("Copie o link:", url)
    }
  }

  fechar() {
    if (this.hasMenuTarget) this.menuTarget.classList.add("hidden")
  }

  connect() {
    this._clickFora = (e) => {
      if (!this.element.contains(e.target)) this.fechar()
    }
    document.addEventListener("click", this._clickFora)
  }

  disconnect() {
    document.removeEventListener("click", this._clickFora)
  }
}
