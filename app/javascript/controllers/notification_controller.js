import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dropdown"]

  connect() {
    this._outsideClick = this._onOutsideClick.bind(this)
  }

  toggle() {
    const open = this.dropdownTarget.classList.toggle("hidden")
    if (!open) {
      document.addEventListener("click", this._outsideClick)
    } else {
      document.removeEventListener("click", this._outsideClick)
    }
  }

  close() {
    this.dropdownTarget.classList.add("hidden")
    document.removeEventListener("click", this._outsideClick)
  }

  disconnect() {
    document.removeEventListener("click", this._outsideClick)
  }

  _onOutsideClick(event) {
    if (!this.element.contains(event.target)) this.close()
  }
}
