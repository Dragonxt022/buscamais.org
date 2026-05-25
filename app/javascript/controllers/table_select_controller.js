import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "bulkBar", "selectedCount", "bulkForm"]
  static values = {
    confirmMessage: { type: String, default: "Remover {count} item(s) selecionado(s)?\nEsta ação não pode ser desfeita." }
  }

  onSelectAll(event) {
    const checked = event.currentTarget.checked
    this.checkboxTargets.forEach(cb => { cb.checked = checked })
    this._updateBulkBar()
  }

  onSelect() {
    this._syncSelectAll()
    this._updateBulkBar()
  }

  _syncSelectAll() {
    const all = this.checkboxTargets
    const checkedCount = all.filter(cb => cb.checked).length
    const sa = this.element.querySelector("[data-select-all]")
    if (!sa) return
    sa.checked = checkedCount === all.length && all.length > 0
    sa.indeterminate = checkedCount > 0 && checkedCount < all.length
  }

  _updateBulkBar() {
    const count = this.checkboxTargets.filter(cb => cb.checked).length
    this.bulkBarTarget.classList.toggle("hidden", count === 0)
    if (this.hasSelectedCountTarget)
      this.selectedCountTarget.textContent = `${count} selecionado${count !== 1 ? "s" : ""}`
  }

  cancelSelection() {
    this.checkboxTargets.forEach(cb => { cb.checked = false })
    const sa = this.element.querySelector("[data-select-all]")
    if (sa) { sa.checked = false; sa.indeterminate = false }
    this._updateBulkBar()
  }

  deleteSelected() {
    const selected = this.checkboxTargets.filter(cb => cb.checked)
    if (!selected.length) return
    const count = selected.length
    const msg = this.confirmMessageValue.replace("{count}", count)
    if (!confirm(msg)) return

    const form = this.bulkFormTarget
    form.querySelectorAll('input[name="ids[]"]').forEach(el => el.remove())
    selected.forEach(cb => {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = "ids[]"
      input.value = cb.value
      form.appendChild(input)
    })
    form.submit()
  }
}
