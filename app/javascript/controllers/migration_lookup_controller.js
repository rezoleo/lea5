import { Controller } from "@hotwired/stimulus"

// Shows "or send an email to j***@g***.com" once the typed re2o username matches an account
export default class extends Controller {
  static targets = ["emailLink", "maskedEmail"]
  static values = { url: String }

  lookup(event) {
    clearTimeout(this.timer)
    this.emailLinkTarget.hidden = true
    const identifier = event.target.value.trim()
    if (!identifier) return

    this.timer = setTimeout(async () => {
      try {
        const response = await fetch(`${this.urlValue}?identifier=${encodeURIComponent(identifier)}`, {
          headers: { Accept: "application/json" },
        })
        const { masked_email } = await response.json()
        // Ignore answers for a value the user has already changed
        if (!masked_email || event.target.value.trim() !== identifier) return
        this.maskedEmailTarget.textContent = masked_email
        this.emailLinkTarget.hidden = false
      } catch {
        // Rate limited or offline: the password path still works
      }
    }, 400)
  }

  disconnect() {
    clearTimeout(this.timer)
  }
}
