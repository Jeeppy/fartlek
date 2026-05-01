import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { delay: { type: Number, default: 5000 } };

  connect() {
    this.timeout = setTimeout(() => this.dismiss(), this.delayValue);
  }

  dismiss() {
    this.element.classList.add("transition", "duration-300", "opacity-0");
    setTimeout(() => this.element.remove(), 300);
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout);
  }
}
