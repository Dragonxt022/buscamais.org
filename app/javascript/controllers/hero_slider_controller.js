import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slide", "dot"]
  static values = { interval: { type: Number, default: 7000 } }

  connect() {
    this.index = 0
    this.play()
    this.onEnter = () => this.stop()
    this.onLeave = () => this.play()
    this.element.addEventListener("mouseenter", this.onEnter)
    this.element.addEventListener("mouseleave", this.onLeave)
  }

  disconnect() {
    this.stop()
    this.element.removeEventListener("mouseenter", this.onEnter)
    this.element.removeEventListener("mouseleave", this.onLeave)
  }

  play() {
    if (this.slideTargets.length <= 1) return
    this.stop()
    this.timer = setInterval(() => this.next(), this.intervalValue)
  }

  stop() {
    if (this.timer) clearInterval(this.timer)
  }

  next() {
    this.show(this.index + 1)
  }

  prev() {
    this.show(this.index - 1)
  }

  goTo(event) {
    this.show(parseInt(event.currentTarget.dataset.index, 10))
    this.play()
  }

  show(newIndex) {
    const total = this.slideTargets.length
    this.index = (newIndex + total) % total

    this.slideTargets.forEach((slide, i) => {
      const active = i === this.index
      slide.classList.toggle("opacity-100", active)
      slide.classList.toggle("z-10", active)
      slide.classList.toggle("opacity-0", !active)
      slide.classList.toggle("z-0", !active)
      slide.classList.toggle("pointer-events-none", !active)
    })

    this.dotTargets.forEach((dot, i) => {
      const active = i === this.index
      dot.classList.toggle("bg-white", active)
      dot.classList.toggle("w-6", active)
      dot.classList.toggle("bg-white/40", !active)
    })
  }
}
