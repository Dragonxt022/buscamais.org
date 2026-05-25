import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mobileMenu", "hamburgerOpen", "hamburgerClose"]

  toggleMobile() {
    const isOpen = !this.mobileMenuTarget.classList.contains("hidden")
    this.mobileMenuTarget.classList.toggle("hidden", isOpen)
    this.hamburgerOpenTarget.classList.toggle("hidden", !isOpen)
    this.hamburgerCloseTarget.classList.toggle("hidden", isOpen)
    document.body.classList.toggle("overflow-hidden", !isOpen)
  }

  closeMobile() {
    this.mobileMenuTarget.classList.add("hidden")
    this.hamburgerOpenTarget.classList.remove("hidden")
    this.hamburgerCloseTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }
}
