import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.hero = document.getElementById("hero-section")
    if (!this.hero) return

    this.element.classList.add("nav-hero")
    this.handleScroll = this.onScroll.bind(this)
    window.addEventListener("scroll", this.handleScroll, { passive: true })
  }

  onScroll() {
    if (this.element.classList.contains("nav-mega-open")) return
    const heroBottom = this.hero.getBoundingClientRect().bottom
    this.element.classList.toggle("nav-hero", heroBottom > this.element.offsetHeight)
  }

  disconnect() {
    window.removeEventListener("scroll", this.handleScroll)
    this.element.classList.remove("nav-hero")
  }
}
