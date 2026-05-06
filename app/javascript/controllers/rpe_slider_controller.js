import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["slider", "value"];

  static LABELS = {
    1: "Très facile",
    2: "Facile",
    3: "Facile",
    4: "Modéré",
    5: "Modéré",
    6: "Difficile",
    7: "Difficile",
    8: "Très difficile",
    9: "Très difficile",
    10: "Maximal",
  };

  static COLORS = {
    1: "text-green-400",
    2: "text-green-400",
    3: "text-green-400",
    4: "text-yellow-400",
    5: "text-yellow-400",
    6: "text-orange-400",
    7: "text-orange-400",
    8: "text-red-400",
    9: "text-red-400",
    10: "text-red-500",
  };

  connect() {
    this.update();
  }

  update() {
    const val = this.sliderTarget.value;
    const label = this.constructor.LABELS[val] || "";
    const color = this.constructor.COLORS[val] || "text-gray-400";

    this.valueTarget.innerHTML = `<span class="${color}">${val}/10 — ${label}</span>`;
  }
}
