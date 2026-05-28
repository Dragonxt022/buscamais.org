import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const img = this.element.tagName === "IMG"
      ? this.element
      : this.element.querySelector("img")
    if (!img) return

    if (img.complete && img.naturalWidth > 0) {
      this._reveal()
    } else {
      img.addEventListener("load",  () => this._reveal(), { once: true })
      img.addEventListener("error", () => this._reveal(), { once: true })
    }
  }

  _reveal() {
    this.element.classList.remove("shimmer")
    const img = this.element.querySelector("img")
    if (img) img.style.opacity = "1"
  }
}
