import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["checkbox"];

  toggle(event) {
    const label = event.currentTarget;
    const checkbox = label.querySelector("input[type=checkbox]");
    const span = label.querySelector("span");

    if (checkbox.checked) {
      span.classList.add("ring-2", "ring-indigo-500", "bg-gray-800");
      span.classList.remove("ring-gray-700", "bg-gray-900");
    } else {
      span.classList.remove("ring-2", "ring-indigo-500", "bg-gray-800");
      span.classList.add("ring-gray-700", "bg-gray-900");
    }
  }
}
