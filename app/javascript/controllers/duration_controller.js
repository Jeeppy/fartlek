import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["hours", "minutes", "hidden"];

  connect() {
    const total = parseInt(this.hiddenTarget.value) || 0;
    this.hoursTarget.value = Math.floor(total / 3600);
    this.minutesTarget.value = Math.floor((total % 3600) / 60);
  }

  update() {
    const hours = parseInt(this.hoursTarget.value) || 0;
    const minutes = parseInt(this.minutesTarget.value) || 0;
    this.hiddenTarget.value = hours * 3600 + minutes * 60;
  }
}
