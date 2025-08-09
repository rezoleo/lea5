import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["wifiPassword", "eyeIcon", "copyMessage"]
  copyToClipboard() {
  const text = this.wifiPasswordTarget.value;
  const copyMessage = this.copyMessageTarget;
  navigator.clipboard.writeText(text);
  copyMessage.style.visibility = "visible";
  copyMessage.style.opacity = 1;
  setTimeout(() => {
    copyMessage.style.visibility = "hidden";
    copyMessage.style.opacity = 0;
  }, 2000);
  }

  togglePasswordVisibility() {
    const passwordField = this.wifiPasswordTarget;
    const eyeIcon = this.eyeIconTargets[0];
    const eyeSlashIcon = this.eyeIconTargets[1];

    if (passwordField.type === "password") {
      passwordField.type = "text";
      eyeIcon.style.display = "inline";
      eyeSlashIcon.style.display = "none";
    } else {
      passwordField.type = "password";
      eyeIcon.style.display = "none";
      eyeSlashIcon.style.display = "inline";
    }
  }


}