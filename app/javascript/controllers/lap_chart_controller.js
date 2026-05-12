import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { laps: Array, hrZones: Array, paceZones: Array };
  static targets = ["canvas", "tab"];

  connect() {
    this.chart = null;
    this.currentMetric = "pace";
    this.render();
  }

  switch(event) {
    event.preventDefault();
    this.currentMetric = event.currentTarget.dataset.metric;
    this.tabTargets.forEach((tab) => {
      tab.classList.toggle(
        "bg-indigo-600",
        tab.dataset.metric === this.currentMetric,
      );
      tab.classList.toggle(
        "text-white",
        tab.dataset.metric === this.currentMetric,
      );
      tab.classList.toggle(
        "bg-gray-800",
        tab.dataset.metric !== this.currentMetric,
      );
      tab.classList.toggle(
        "text-gray-400",
        tab.dataset.metric !== this.currentMetric,
      );
    });
    this.render();
  }

  render() {
    if (this.chart) this.chart.destroy();

    const laps = this.lapsValue;
    const labels = laps.map((l) => `${l.number}`);
    const config = this.metricConfig();
    const values = laps.map((l) => l[config.key]).filter((v) => v != null);

    if (values.length === 0) return;

    const rawValues = laps.map((l) => l[config.key]);

    this.chart = new Chart(this.canvasTarget, {
      type: "bar",
      data: {
        labels: labels,
        datasets: [
          {
            data: config.invert
              ? rawValues.map((v) => (v ? config.max - v : null))
              : rawValues,
            backgroundColor: config.colorFn
              ? rawValues.map((v) => (v ? config.colorFn(v) : "#374151"))
              : `${config.color}80`,
            borderColor: config.colorFn
              ? rawValues.map((v) =>
                  v ? config.colorFn(v).slice(0, 7) : "#374151",
                )
              : config.color,
            borderWidth: 1,
            borderRadius: 4,
          },
        ],
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: false },
          tooltip: {
            callbacks: {
              label: (ctx) => {
                const real = rawValues[ctx.dataIndex];
                return real ? config.format(real) : "—";
              },
            },
          },
        },
        scales: {
          y: {
            grid: { color: "#1f2937" },
            ticks: {
              color: "#9ca3af",
              callback: (value) => {
                if (config.invert) return config.format(config.max - value);
                return config.format(value);
              },
            },
          },
          x: {
            grid: { display: false },
            ticks: { color: "#9ca3af" },
          },
        },
      },
    });
  }

  metricConfig() {
    const formatPace = (s) => {
      const m = Math.floor(s / 60);
      const sec = Math.round(s % 60);
      return `${m}:${sec.toString().padStart(2, "0")} /km`;
    };

    const getZoneColor = (zones, value, invert = false) => {
      if (!zones || zones.length === 0) return null;
      const v = invert ? value : value;
      const zone = zones.find((z) => v >= z.min && v <= z.max);
      return zone ? zone.color + "cc" : null;
    };

    const configs = {
      pace: {
        key: "pace",
        color: "#818cf8",
        invert: true,
        max: Math.max(...this.lapsValue.map((l) => l.pace || 0)) + 30,
        format: formatPace,
        colorFn: (raw) => getZoneColor(this.paceZonesValue, raw) || "#818cf8cc",
      },
      hr: {
        key: "hr",
        color: "#ef4444",
        invert: false,
        format: (v) => `${v} bpm`,
        colorFn: (raw) => getZoneColor(this.hrZonesValue, raw) || "#ef4444cc",
      },
      cadence: {
        key: "cadence",
        color: "#22c55e",
        invert: false,
        format: (v) => `${v} spm`,
        colorFn: null,
      },
      power: {
        key: "power",
        color: "#f59e0b",
        invert: false,
        format: (v) => `${v} W`,
        colorFn: null,
      },
    };
    return configs[this.currentMetric];
  }
}
