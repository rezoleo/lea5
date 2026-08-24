import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["wifiPassword", "eyeIcon", "copyMessage"]
  static values = { password: String }

  connect() {
    // Browsers blank out <input type="password"> values when a page is restored
    // from the back/forward cache, so put it back from the value we kept in the DOM.
    this.restorePassword = ({ persisted }) => {
      if (persisted) this.wifiPasswordTarget.value = this.passwordValue
    }
    window.addEventListener("pageshow", this.restorePassword)
  }

  disconnect() {
    window.removeEventListener("pageshow", this.restorePassword)
  }

  copyToClipboard() {
    const copyMessage = this.copyMessageTarget
    navigator.clipboard.writeText(this.passwordValue)
    copyMessage.classList.remove("hidden")
    setTimeout(() => {
      copyMessage.classList.add("hidden")
    }, 2000)
  }

  togglePasswordVisibility(event) {
    const passwordField = this.wifiPasswordTarget
    const revealing = passwordField.type === "password"
    passwordField.type = revealing ? "text" : "password"
    this.eyeIconTargets.forEach((icon) => icon.classList.toggle("hidden"))
    event.currentTarget.setAttribute("aria-label", revealing ? "Hide wifi password" : "Show wifi password")
  }
}
