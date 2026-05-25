import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["replies", "label", "icon"]
  static values  = { count: Number, open: { type: Boolean, default: false } }

  toggle() {
    this.openValue = !this.openValue
  }

  openValueChanged() {
    if (!this.hasRepliesTarget) return
    this.repliesTarget.classList.toggle("hidden", !this.openValue)
    this._updateLabel()
    if (this.hasIconTarget) {
      this.iconTarget.style.transform = this.openValue ? "rotate(180deg)" : ""
    }
  }

  _updateLabel() {
    if (!this.hasLabelTarget) return
    const n    = this.countValue
    const word = n === 1 ? "resposta" : "respostas"
    this.labelTarget.textContent = this.openValue ? "Ocultar respostas" : `Ver ${n} ${word}`
  }
}
