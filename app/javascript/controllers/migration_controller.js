import { Controller } from "@hotwired/stimulus"

const ROW_DELAY = 650 // ms between two rows
const SPIN_TIME = 550 // ms a row spins before its result shows

// Replays the import as a sequence: each row spins, then resolves, then the wifi card.
// Without JS, or with reduced motion, everything is shown at once.
export default class extends Controller {
  static targets = ["row", "finale"]

  connect() {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return

    this.timers = []
    this.element.classList.add("is-animated")
    this.rowTargets.forEach((row, i) => {
      this.later(i * ROW_DELAY, () => row.classList.add("is-running"))
      this.later(i * ROW_DELAY + SPIN_TIME, () => {
        row.classList.add("is-resolved")
        row.querySelectorAll("[data-count-to]").forEach((el) => this.countUp(el))
      })
    })

    const end = this.rowTargets.length * ROW_DELAY + SPIN_TIME
    this.later(end, () => {
      this.finaleTarget.classList.add("is-visible")
      this.finaleTarget.scrollIntoView({ behavior: "smooth", block: "nearest" })
    })
  }

  disconnect() {
    this.timers?.forEach(clearTimeout)
  }

  later(ms, fn) {
    this.timers.push(setTimeout(fn, ms))
  }

  countUp(el) {
    const target = Number(el.dataset.countTo)
    const duration = 1200
    const start = performance.now()
    const tick = (now) => {
      const t = Math.min((now - start) / duration, 1)
      el.textContent = Math.round(target * (1 - Math.pow(1 - t, 3))) // ease-out cubic
      if (t < 1) requestAnimationFrame(tick)
    }
    el.textContent = "0"
    requestAnimationFrame(tick)
  }
}
