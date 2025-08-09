import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["wifiPassword", "eyeIcon"]
  copyToClipboard() {
  const text = this.wifiPasswordTarget.value;
  navigator.clipboard.writeText(text);
  console.log("Copied to clipboard:", text);
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