import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["corpo", "colapsado", "linha", "respostas"]
  static values  = { nivel: Number }

  toggle() {
    const collapsed = this.corpoTarget.classList.contains("hidden")
    if (collapsed) {
      this.corpoTarget.classList.remove("hidden")
      this.colapsadoTarget.classList.remove("flex")
      this.colapsadoTarget.classList.add("hidden")
      if (this.hasLinhaTarget) this.linhaTarget.classList.remove("opacity-30")
    } else {
      this.corpoTarget.classList.add("hidden")
      this.colapsadoTarget.classList.remove("hidden")
      this.colapsadoTarget.classList.add("flex")
      if (this.hasLinhaTarget) this.linhaTarget.classList.add("opacity-30")
    }
  }
}
