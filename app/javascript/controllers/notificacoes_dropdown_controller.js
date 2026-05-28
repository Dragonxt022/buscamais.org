import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["painel"]

  toggle(event) {
    event.stopPropagation()
    this.painelTarget.classList.toggle("hidden")
  }

  fechar() {
    this.painelTarget.classList.add("hidden")
  }

  // Fecha ao clicar fora
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
