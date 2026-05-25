import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["label"]

  copyLink() {
    const url = this.element.dataset.shareUrl || window.location.href
    navigator.clipboard?.writeText(url).then(() => {
      if (this.hasLabelTarget) {
        this.labelTarget.textContent = "Copiado!"
        setTimeout(() => { this.labelTarget.textContent = "Copiar link" }, 2000)
      }
    }).catch(() => {
      // fallback for older browsers
      const ta = document.createElement("textarea")
      ta.value = url
      document.body.appendChild(ta)
      ta.select()
      document.execCommand("copy")
      document.body.removeChild(ta)
      if (this.hasLabelTarget) {
        this.labelTarget.textContent = "Copiado!"
        setTimeout(() => { this.labelTarget.textContent = "Copiar link" }, 2000)
      }
    })
  }
}
