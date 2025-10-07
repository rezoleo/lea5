import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["wifiPassword", "eyeIcon", "copyMessage"]
  static values = { password: String }

  copyToClipboard() {
    const text = this.passwordValue
    const copyMessage = this.copyMessageTarget
    navigator.clipboard.writeText(text)
    copyMessage.classList.add("visible")
    setTimeout(() => {
      copyMessage.classList.remove("visible")
    }, 2000)
  }

  togglePasswordVisibility() {
    const passwordField = this.wifiPasswordTarget
    const eyeIcon = this.eyeIconTargets[0]
    const eyeSlashIcon = this.eyeIconTargets[1]

    if (passwordField.classList.contains("visible")) {
      passwordField.classList.remove("visible")
      passwordField.textContent = "********************"
      eyeIcon.classList.replace("eye-visible", "eye-hidden")
      eyeSlashIcon.classList.replace("eye-hidden", "eye-visible")
    } else {
      passwordField.classList.add("visible")
      passwordField.textContent = this.passwordValue
      eyeIcon.classList.replace("eye-hidden", "eye-visible")
      eyeSlashIcon.classList.replace("eye-visible", "eye-hidden")
    }
  }
}
