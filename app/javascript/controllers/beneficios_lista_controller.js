import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["lista"]

  adicionar() {
    const item = document.createElement("div")
    item.className = "flex items-center gap-2 beneficio-item"
    item.innerHTML = `
      <svg class="w-4 h-4 text-gray-300 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
      </svg>
      <input type="text" name="plano[beneficios][]"
             placeholder="Ex: Salvar matérias ilimitadas"
             class="input text-sm flex-1"
             autofocus>
      <button type="button"
              data-action="click->beneficios-lista#remover"
              class="p-1.5 text-gray-300 hover:text-red-500 rounded transition-colors shrink-0">
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
        </svg>
      </button>
    `
    this.listaTarget.appendChild(item)
    item.querySelector("input").focus()
  }

  remover(event) {
    event.currentTarget.closest(".beneficio-item").remove()
  }
}
