import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { delay: { type: Number, default: 3500 } }

  connect() {
    this._timer = setTimeout(() => this.dismiss(), this.delayValue)
  }

  disconnect() {
    clearTimeout(this._timer)
  }

  dismiss() {
    this.element.style.transition = "opacity 300ms ease, transform 300ms ease"
    this.element.style.opacity    = "0"
    this.element.style.transform  = "translateY(-8px)"
    setTimeout(() => this.element.remove(), 300)
  }
}
