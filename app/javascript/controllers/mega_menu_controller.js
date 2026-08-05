import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel"]

  connect() {
    this._closeTimer = null
  }

  show(event) {
    const id = String(event.currentTarget.dataset.categoryId)
    clearTimeout(this._closeTimer)

    // Force nav solid while mega-menu is open
    this.element.classList.remove("nav-hero")
    this.element.classList.add("nav-mega-open")

    this.panelTargets.forEach(panel => {
      if (String(panel.dataset.categoryId) === id) {
        panel.classList.remove("hidden")
      } else {
        panel.classList.add("hidden")
      }
    })
  }

  hide() {
    this._closeTimer = setTimeout(() => {
      this.panelTargets.forEach(p => p.classList.add("hidden"))
      this.element.classList.remove("nav-mega-open")
      // Re-trigger hero check so nav-hero is restored if hero still visible
      window.dispatchEvent(new Event("scroll", { bubbles: false }))
    }, 120)
  }

  keepOpen() {
    clearTimeout(this._closeTimer)
  }
}
