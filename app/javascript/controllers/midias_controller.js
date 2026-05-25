import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "item", "checkbox",
    "bulkBar", "selectedCount",
    "gridView", "listView",
    "editModal", "editNome", "editDescricao", "editUrl", "editPreview"
  ]

  connect() {
    this._setView(localStorage.getItem("midias-view") || "grid", false)
  }

  // ── View toggle ─────────────────────────────────────────────────────────────

  setGrid() { this._setView("grid") }
  setList() { this._setView("list") }

  _setView(mode, save = true) {
    const isGrid = mode === "grid"
    this.gridViewTarget.classList.toggle("hidden", !isGrid)
    this.listViewTarget.classList.toggle("hidden",  isGrid)
    this.element.querySelectorAll("[data-view-btn]").forEach(btn => {
      const active = btn.dataset.viewBtn === mode
      btn.classList.toggle("bg-white",   active)
      btn.classList.toggle("shadow-sm",  active)
      btn.classList.toggle("text-gray-800", active)
      btn.classList.toggle("text-gray-400", !active)
    })
    this._clearSelection()
    if (save) localStorage.setItem("midias-view", mode)
  }

  // ── Selection ────────────────────────────────────────────────────────────────

  onSelectAll(event) {
    const container = event.currentTarget.closest("[data-midias-target='gridView'],[data-midias-target='listView']")
    const checked   = event.currentTarget.checked
    container?.querySelectorAll("[data-midias-target='checkbox']").forEach(cb => {
      cb.checked = checked
      this._ringItem(cb, checked)
    })
    this._updateBulkBar()
  }

  onSelect(event) {
    this._ringItem(event.currentTarget, event.currentTarget.checked)
    this._syncSelectAll(event.currentTarget)
    this._updateBulkBar()
  }

  _ringItem(checkbox, on) {
    const item = checkbox.closest("[data-midias-target='item']")
    item?.classList.toggle("ring-2",       on)
    item?.classList.toggle("ring-blue-500", on)
    item?.classList.toggle("ring-offset-1", on)
  }

  _syncSelectAll(checkbox) {
    const container = checkbox.closest("[data-midias-target='gridView'],[data-midias-target='listView']")
    if (!container) return
    const all     = container.querySelectorAll("[data-midias-target='checkbox']")
    const checked = Array.from(all).filter(c => c.checked).length
    const sa      = container.querySelector("[data-select-all]")
    if (!sa) return
    sa.checked       = checked === all.length && all.length > 0
    sa.indeterminate = checked > 0 && checked < all.length
  }

  _updateBulkBar() {
    const count = this.checkboxTargets.filter(c => c.checked).length
    this.bulkBarTarget.classList.toggle("hidden", count === 0)
    if (this.hasSelectedCountTarget)
      this.selectedCountTarget.textContent = `${count} selecionado${count !== 1 ? "s" : ""}`
  }

  _clearSelection() {
    this.checkboxTargets.forEach(cb => { cb.checked = false; this._ringItem(cb, false) })
    this.element.querySelectorAll("[data-select-all]").forEach(sa => {
      sa.checked = false; sa.indeterminate = false
    })
    this._updateBulkBar()
  }

  cancelSelection() { this._clearSelection() }

  // ── Edit modal ───────────────────────────────────────────────────────────────

  openEdit(event) {
    const item = event.currentTarget.closest("[data-midias-target='item']")
    const { updateUrl, nome, descricao, previewUrl } = item.dataset
    this.editUrlTarget.value       = updateUrl || ""
    this.editNomeTarget.value      = nome      || ""
    this.editDescricaoTarget.value = descricao || ""
    if (previewUrl) {
      this.editPreviewTarget.src = previewUrl
      this.editPreviewTarget.classList.remove("hidden")
    } else {
      this.editPreviewTarget.classList.add("hidden")
    }
    this.editModalTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
    setTimeout(() => this.editNomeTarget.select(), 50)
  }

  closeEdit() {
    this.editModalTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }

  closeEditBackdrop(event) {
    if (event.target === this.editModalTarget) this.closeEdit()
  }

  async saveEdit(event) {
    event.preventDefault()
    const url  = this.editUrlTarget.value
    const csrf = document.querySelector('meta[name="csrf-token"]')?.content
    const btn  = event.currentTarget
    btn.disabled = true
    btn.textContent = "Salvando..."

    const form = new FormData()
    form.append("media_file[nome]",      this.editNomeTarget.value)
    form.append("media_file[descricao]", this.editDescricaoTarget.value)
    form.append("_method", "PATCH")

    try {
      const resp = await fetch(url, {
        method: "POST",
        headers: { "X-CSRF-Token": csrf, Accept: "application/json" },
        body: form
      })
      if (resp.ok) {
        const midia = await resp.json()
        this.itemTargets
          .filter(el => el.dataset.updateUrl === url)
          .forEach(el => {
            el.dataset.nome      = midia.nome
            el.dataset.descricao = midia.descricao || ""
            el.querySelectorAll("[data-nome-label]").forEach(l => l.textContent = midia.nome)
          })
        this.closeEdit()
      } else {
        btn.textContent = "Erro"; btn.disabled = false
      }
    } catch {
      btn.textContent = "Erro"; btn.disabled = false
    }
  }

  // ── Delete single ─────────────────────────────────────────────────────────────

  async deleteOne(event) {
    event.preventDefault()
    const item       = event.currentTarget.closest("[data-midias-target='item']")
    const { deleteUrl, nome, id } = item.dataset
    if (!confirm(`Remover "${nome}"?\nEsta ação não pode ser desfeita.`)) return

    const csrf = document.querySelector('meta[name="csrf-token"]')?.content
    event.currentTarget.disabled = true

    const resp = await fetch(deleteUrl, {
      method: "DELETE",
      headers: { "X-CSRF-Token": csrf, Accept: "application/json" }
    })
    if (resp.ok) {
      this.itemTargets.filter(el => el.dataset.id === id).forEach(el => el.remove())
      this._updateBulkBar()
    } else {
      event.currentTarget.disabled = false
    }
  }

  // ── Bulk delete ───────────────────────────────────────────────────────────────

  async deleteSelected(event) {
    const selected = this.checkboxTargets
      .filter(cb => cb.checked)
      .map(cb => cb.closest("[data-midias-target='item']"))
      .filter(Boolean)
    if (!selected.length) return

    const seen   = new Set()
    const unique = selected.filter(el => !seen.has(el.dataset.id) && seen.add(el.dataset.id))
    const count  = unique.length

    if (!confirm(`Remover ${count} arquivo${count !== 1 ? "s" : ""}?\nEsta ação não pode ser desfeita.`)) return

    const btn  = event.currentTarget
    const csrf = document.querySelector('meta[name="csrf-token"]')?.content
    btn.disabled = true
    btn.textContent = "Removendo..."

    await Promise.allSettled(unique.map(async item => {
      const resp = await fetch(item.dataset.deleteUrl, {
        method: "DELETE",
        headers: { "X-CSRF-Token": csrf, Accept: "application/json" }
      })
      if (resp.ok)
        this.itemTargets.filter(el => el.dataset.id === item.dataset.id).forEach(el => el.remove())
    }))

    this._clearSelection()
    btn.disabled = false
    btn.textContent = "Excluir selecionados"
  }
}
