import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "toggle"]

  toggle() {
    const hidden = this.formTarget.classList.toggle("hidden")
    if (!hidden) {
      this.formTarget.querySelector("textarea")?.focus()
    }
  }
}
