import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  abrir(event) {
    // Fecha o menu pai (...)
    const menu = this.element.closest("[data-controller='comment-menu']")
    if (menu) {
      const menuEl = menu.querySelector("[data-comment-menu-target='menu']")
      if (menuEl) menuEl.classList.add("hidden")
    }

    // Encontra o modal pelo ID derivado da URL do form
    const commentId = this.urlValue.match(/\/(\d+)\/denunciar/)?.[1]
    if (commentId) {
      const modal = document.getElementById(`report-modal-${commentId}`)
      if (modal) modal.classList.remove("hidden")
    }
  }
}
