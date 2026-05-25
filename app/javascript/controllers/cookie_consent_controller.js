import { Controller } from "@hotwired/stimulus"

// Scripts marcados com type="text/plain" data-consent="analytics" ficam completamente
// bloqueados pelo browser. Ao aceitar, são recriados como type="text/javascript" e executam.
export default class extends Controller {
  connect() {
    requestAnimationFrame(() => {
      this.element.classList.remove("translate-y-full")
    })
  }

  async accept() {
    await this._saveConsent("accepted")
    this._activatePendingScripts()
    this._dismiss()
  }

  async reject() {
    await this._saveConsent("rejected")
    this._dismiss()
  }

  // ── Animação de saída ──────────────────────────────────────────────────────
  _dismiss() {
    this.element.classList.add("translate-y-full")
    setTimeout(() => this.element.remove(), 500)
  }

  // ── Salva consentimento no servidor (grava cookie HttpOnly via Rails) ───────
  async _saveConsent(value) {
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    try {
      await fetch("/cookie_consent", {
        method:  "POST",
        headers: { "Content-Type": "application/json", "X-CSRF-Token": token },
        body:    JSON.stringify({ consent: value })
      })
    } catch {
      // fallback: salva no cookie do cliente diretamente
      const expires = new Date(Date.now() + 365 * 864e5).toUTCString()
      document.cookie = `cookie_consent=${value}; expires=${expires}; path=/; SameSite=Lax`
    }
  }

  // ── Ativa scripts de analytics que estavam bloqueados ─────────────────────
  // Scripts com type="text/plain" são ignorados pelo browser — trocar o type
  // para "text/javascript" (ou removê-lo) dispara a execução normalmente.
  _activatePendingScripts() {
    document.querySelectorAll('script[type="text/plain"][data-consent="analytics"]').forEach(blocked => {
      const live = document.createElement("script")
      Array.from(blocked.attributes).forEach(a => {
        if (a.name === "type") return
        live.setAttribute(a.name, a.value)
      })
      if (blocked.textContent.trim()) live.textContent = blocked.textContent
      blocked.replaceWith(live)
    })
  }
}
