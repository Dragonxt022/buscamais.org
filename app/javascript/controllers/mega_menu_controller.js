import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel"]

  connect() {
    this._closeTimer = null
  }

  show(event) {
    const id = String(event.currentTarget.dataset.categoryId)
    clearTimeout(this._closeTimer)

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
    }, 120)
  }

  keepOpen() {
    clearTimeout(this._closeTimer)
  }
}
