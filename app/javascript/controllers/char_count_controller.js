import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "counter", "submit"]
  static values  = { max: Number, min: { type: Number, default: 1 } }

  connect() {
    this.atualizar()
  }

  atualizar() {
    const len     = this.inputTarget.value.length
    const max     = this.maxValue
    const min     = this.minValue
    const restam  = max - len
    const pct     = len / max

    // Atualiza texto do contador
    if (this.hasCounterTarget) {
      this.counterTarget.textContent = `${len}/${max}`

      this.counterTarget.classList.remove("text-gray-400", "text-amber-500", "text-red-500", "font-bold")
      if (len > max) {
        this.counterTarget.classList.add("text-red-500", "font-bold")
      } else if (pct >= 0.85) {
        this.counterTarget.classList.add("text-amber-500")
      } else {
        this.counterTarget.classList.add("text-gray-400")
      }
    }

    // Bloqueia submit quando fora dos limites
    const invalido = len > max || len < min
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = invalido
      this.submitTarget.classList.toggle("opacity-50", invalido)
      this.submitTarget.classList.toggle("cursor-not-allowed", invalido)
    }

    // Destaque visual no campo quando excede
    this.inputTarget.classList.toggle("border-red-400", len > max)
    this.inputTarget.classList.toggle("ring-1",         len > max)
    this.inputTarget.classList.toggle("ring-red-300",   len > max)
  }
}
