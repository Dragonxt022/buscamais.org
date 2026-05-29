import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "chips", "suggestion"]

  connect() {
    this._render()
  }

  // Clique em sugestão existente — alterna seleção
  toggle(event) {
    event.preventDefault()
    const nome = event.currentTarget.dataset.tagName
    const tags = this._getTags()
    const idx  = tags.findIndex(t => t.toLowerCase() === nome.toLowerCase())
    if (idx >= 0) {
      tags.splice(idx, 1)
    } else {
      tags.push(nome)
    }
    this.inputTarget.value = tags.join(", ")
    this._render()
  }

  // Tecla Enter ou vírgula no input — normaliza
  keydown(event) {
    if (event.key === "Enter") event.preventDefault()
    if (event.key === "Enter" || event.key === ",") {
      this._normalize()
      this._render()
    }
    if (event.key === "Backspace" && this._rawTail() === "") {
      const tags = this._getTags()
      tags.pop()
      this.inputTarget.value = tags.join(", ")
      this._render()
    }
  }

  // Ao perder foco normaliza
  blur() {
    this._normalize()
    this._render()
  }

  // ── Internos ──────────────────────────────────────────────────────────────

  _getTags() {
    return this.inputTarget.value
      .split(",")
      .map(t => t.trim())
      .filter(t => t.length > 0)
  }

  _rawTail() {
    return this.inputTarget.value.split(",").pop().trim()
  }

  _normalize() {
    this.inputTarget.value = this._getTags().join(", ")
  }

  _render() {
    const selected = this._getTags().map(t => t.toLowerCase())

    // Renderiza chips visuais acima do input
    if (this.hasChipsTarget) {
      this.chipsTarget.innerHTML = selected.map(nome => `
        <span class="inline-flex items-center gap-1 bg-blue-100 text-blue-800 text-xs font-semibold px-2.5 py-1 rounded-full">
          #${this._esc(nome)}
          <button type="button" class="ml-0.5 text-blue-500 hover:text-blue-900 leading-none"
                  data-action="click->tag-input#removeChip"
                  data-chip-name="${this._esc(nome)}">&times;</button>
        </span>
      `).join("")
    }

    // Destaca sugestões já selecionadas
    if (this.hasSuggestionTargets) {
      this.suggestionTargets.forEach(btn => {
        const isSelected = selected.includes(btn.dataset.tagName.toLowerCase())
        if (isSelected) {
          btn.classList.add("bg-blue-600", "text-white", "border-blue-600")
          btn.classList.remove("bg-white", "text-gray-600", "border-gray-200", "hover:border-blue-400")
        } else {
          btn.classList.remove("bg-blue-600", "text-white", "border-blue-600")
          btn.classList.add("bg-white", "text-gray-600", "border-gray-200", "hover:border-blue-400")
        }
      })
    }
  }

  removeChip(event) {
    const nome = event.currentTarget.dataset.chipName
    const tags = this._getTags().filter(t => t.toLowerCase() !== nome.toLowerCase())
    this.inputTarget.value = tags.join(", ")
    this._render()
  }

  _esc(str) {
    return String(str).replace(/[&<>"']/g, c =>
      ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]))
  }
}
