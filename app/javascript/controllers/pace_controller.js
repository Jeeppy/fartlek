import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["minutes", "seconds", "hidden"];

  connect() {
    const total = parseInt(this.hiddenTarget.value) || 0;
    this.minutesTarget.value = Math.floor(total / 60);
    this.secondsTarget.value = total % 60;
  }

  update() {
    const minutes = parseInt(this.minutesTarget.value) || 0;
    const seconds = parseInt(this.secondsTarget.value) || 0;
    this.hiddenTarget.value = minutes * 60 + seconds;
  }
}
