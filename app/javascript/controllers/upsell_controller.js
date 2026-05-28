import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  fechar() {
    this.element.classList.add("hidden")
  }
}

// Expõe globalmente para botões inline chamarem sem data-controller
window.abrirUpsell = () => {
  const el = document.getElementById("upsell-modal")
  if (el) el.classList.remove("hidden")
}
