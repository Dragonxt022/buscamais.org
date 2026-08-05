import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mobileMenu", "hamburgerOpen", "hamburgerClose", "searchInput", "searchIcon", "searchClose"]

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

  toggleSearch(e) {
    e.preventDefault()
    const input = this.searchInputTarget
    const isHidden = input.classList.contains("hidden")
    input.classList.toggle("hidden", !isHidden)
    this.searchIconTarget.classList.toggle("hidden", isHidden)
    this.searchCloseTarget.classList.toggle("hidden", !isHidden)
    if (isHidden) {
      input.focus()
    } else {
      input.value = ""
    }
  }

  searchKeydown(e) {
    if (e.key === "Escape") {
      this.searchInputTarget.classList.add("hidden")
      this.searchIconTarget.classList.remove("hidden")
      this.searchCloseTarget.classList.add("hidden")
      this.searchInputTarget.value = ""
    }
  }
}
