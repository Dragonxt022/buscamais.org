import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["icon", "count"]
  static values  = { url: String, liked: Boolean }

  async toggle() {
    const csrf = document.querySelector('meta[name="csrf-token"]')
    try {
      const resp = await fetch(this.urlValue, {
        method:  "POST",
        headers: { "X-CSRF-Token": csrf?.content, Accept: "application/json",
                   "Content-Type": "application/json" }
      })
      if (!resp.ok) return
      const { liked, count } = await resp.json()
      this.likedValue = liked
      this.countTarget.textContent = count
      this.iconTarget.setAttribute("fill", liked ? "currentColor" : "none")
      this.element.classList.toggle("text-blue-600", liked)
      this.element.classList.toggle("text-gray-400", !liked)
    } catch { /* ignore */ }
  }
}
