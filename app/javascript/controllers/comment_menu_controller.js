import { Controller } from "@hotwired/stimulus"

// Menu dropdown do "..." nos comentários (Denunciar, Salvar, etc.)
export default class extends Controller {
  static targets = ["menu"]

  toggle(event) {
    event.stopPropagation()
    const isOpen = !this.menuTarget.classList.contains("hidden")
    // Fecha todos os outros menus abertos
    document.querySelectorAll("[data-comment-menu-target='menu']").forEach(m => {
      m.classList.add("hidden")
    })
    if (!isOpen) this.menuTarget.classList.remove("hidden")
  }

  fechar() {
    this.menuTarget.classList.add("hidden")
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
