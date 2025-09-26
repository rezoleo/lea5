import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["wifiPassword", "eyeIcon", "copyMessage"]
  static values = { password: String }

  copyToClipboard() {
  const text = this.passwordValue;
  const copyMessage = this.copyMessageTarget;
  navigator.clipboard.writeText(text);
  copyMessage.classList.replace("copy-message-hidden", "copy-message-visible");
  setTimeout(() => {
    copyMessage.classList.replace("copy-message-visible", "copy-message-hidden");
  }, 2000);
  }

  togglePasswordVisibility() {
    const passwordField = this.wifiPasswordTarget;
    const eyeIcon = this.eyeIconTargets[0];
    const eyeSlashIcon = this.eyeIconTargets[1];

    if (passwordField.classList.contains("card-content-user-details-password-hidden")) {
      passwordField.classList.replace("card-content-user-details-password-hidden", "card-content-user-details-password-visible");
      eyeIcon.classList.replace("eye-hidden", "eye-visible");
      eyeSlashIcon.classList.replace("eye-visible", "eye-hidden");
      passwordField.textContent = this.passwordValue;
    } else {
      passwordField.classList.replace("card-content-user-details-password-visible", "card-content-user-details-password-hidden");
      eyeIcon.classList.replace("eye-visible", "eye-hidden");
      eyeSlashIcon.classList.replace("eye-hidden", "eye-visible");
      passwordField.textContent = "******";
    }
  }


}