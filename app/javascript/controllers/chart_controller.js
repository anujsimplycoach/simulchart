import { Controller } from "@hotwired/stimulus"
import Highcharts from "highcharts"

export default class extends Controller {
  static values = { type: String }

  connect() {
    // Listen for data pushed by dashboard_controller
    this.element.addEventListener("chart:load", (e) => this.render(e.detail))
  }

  disconnect() {
    this.destroyChart()
  }

  render(payload) {
    this.destroyChart()

    const config = this.buildConfig(payload)
    if (config) Highcharts.chart(this.element.id, config)
  }

  buildConfig(payload) {
    const base = {
      title:   { text: payload.title || '' },
      credits: { enabled: false },
      chart:   { type: payload.chart_type, animation: { duration: 600 } }
    }

    if (payload.chart_type === 'pie') {
      return { ...base, series: payload.series }
    }

    return {
      ...base,
      xAxis:  { categories: payload.xAxis },
      yAxis:  { title: { text: '' } },
      series: payload.series
    }
  }

  destroyChart() {
    const existing = Highcharts.charts.find(c => c && c.renderTo && c.renderTo.id === this.element.id)
    if (existing) existing.destroy()
  }
}
