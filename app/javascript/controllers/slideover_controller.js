import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["panel", "overlay"];

  connect() {
    document.addEventListener("turbo:frame-load", (event) => {
      if (event.target.id === "slideover_content") {
        this.open();
      }
    });
  }

  open() {
    this.panelTarget.classList.remove("translate-x-full");
    this.overlayTarget.classList.remove("hidden");
    document.body.classList.add("overflow-hidden");
  }

  close() {
    this.panelTarget.classList.add("translate-x-full");
    this.overlayTarget.classList.add("hidden");
    document.body.classList.remove("overflow-hidden");
  }
}
