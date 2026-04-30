import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["slider", "value"];

  connect() {
    this.update();
  }

  update() {
    const val = parseInt(this.sliderTarget.value);
    this.valueTarget.textContent = val;

    const colors = {
      1: "text-green-400",
      2: "text-green-400",
      3: "text-lime-400",
      4: "text-lime-400",
      5: "text-yellow-400",
      6: "text-yellow-400",
      7: "text-orange-400",
      8: "text-orange-400",
      9: "text-red-400",
      10: "text-red-400",
    };

    this.valueTarget.className = `mt-1 text-center text-sm font-semibold ${colors[val]}`;
  }
}
