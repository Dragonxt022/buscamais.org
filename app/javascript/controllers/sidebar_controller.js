import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["label", "groupLabel", "brandText", "toggleIcon", "submenu", "submenuArrow"]

  connect() {
    const collapsed = localStorage.getItem("sidebar-collapsed") === "true"
    this._apply(collapsed, false)

    // Auto-open submenu se a página ativa estiver dentro dele
    this.submenuTargets.forEach(menu => {
      if (menu.querySelector(".submenu-active")) {
        menu.classList.remove("hidden")
        const btn = this.element.querySelector(`[data-submenu="${menu.dataset.id}"]`)
        btn?.querySelector("[data-sidebar-target='submenuArrow']")?.classList.add("rotate-180")
      }
    })
  }

  toggle() {
    const collapsed = !this.element.classList.contains("sidebar-collapsed")
    this._apply(collapsed, true)
    localStorage.setItem("sidebar-collapsed", collapsed)
  }

  toggleSubmenu(event) {
    const id   = event.currentTarget.dataset.submenu
    const menu = this.submenuTargets.find(m => m.dataset.id === id)
    if (!menu) return

    // Se recolhido, expandir primeiro
    if (this.element.classList.contains("sidebar-collapsed")) {
      this._apply(false, true)
      localStorage.setItem("sidebar-collapsed", false)
      menu.classList.remove("hidden")
      event.currentTarget.querySelector("[data-sidebar-target='submenuArrow']")?.classList.add("rotate-180")
      return
    }

    const isOpen = !menu.classList.contains("hidden")
    menu.classList.toggle("hidden", isOpen)
    event.currentTarget.querySelector("[data-sidebar-target='submenuArrow']")?.classList.toggle("rotate-180", !isOpen)
  }

  _apply(collapsed, animate) {
    const el = this.element

    if (animate) {
      el.classList.add("transition-all", "duration-200", "ease-in-out")
    } else {
      el.classList.remove("transition-all", "duration-200", "ease-in-out")
    }

    if (collapsed) {
      el.classList.add("sidebar-collapsed")
      el.style.width = "4rem"

      this.labelTargets.forEach(t      => t.classList.add("hidden"))
      this.groupLabelTargets.forEach(t => t.classList.add("hidden"))
      this.submenuTargets.forEach(t    => t.classList.add("hidden"))
      this.submenuArrowTargets.forEach(t => t.classList.add("hidden"))
      if (this.hasBrandTextTarget) this.brandTextTarget.classList.add("hidden")
      this.toggleIconTarget.classList.add("rotate-180")

    } else {
      el.classList.remove("sidebar-collapsed")
      el.style.width = "15rem"

      this.labelTargets.forEach(t      => t.classList.remove("hidden"))
      this.groupLabelTargets.forEach(t => t.classList.remove("hidden"))
      this.submenuArrowTargets.forEach(t => t.classList.remove("hidden"))
      if (this.hasBrandTextTarget) this.brandTextTarget.classList.remove("hidden")
      this.toggleIconTarget.classList.remove("rotate-180")
    }
  }
}
