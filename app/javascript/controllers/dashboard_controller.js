import { Controller } from "@hotwired/stimulus"
import cable from "channels/consumer"

export default class extends Controller {
  static values = {
    stream: String,
    charts: Array
  }

  connect() {
    console.log(`[Dashboard] Connecting to stream: ${this.streamValue}`)
    console.log(`[Dashboard] Charts to load: ${this.chartsValue.length}`)

    // AnyCable API: cable.subscribeTo(channelName, params)
    this.channel = cable.subscribeTo("DashboardChannel", { stream: this.streamValue })

    this.channel.on("connect",    ()     => this.onConnected())
    this.channel.on("disconnect", ()     => console.log("[Dashboard] WS disconnected"))
    this.channel.on("message",    (data) => this.onReceived(data))
    this.channel.on("close",      ()     => console.warn("[Dashboard] channel closed"))
    this.channel.on("error",      (err)  => console.error("[Dashboard] channel error", err))
  }

  disconnect() {
    this.stopHeartbeat()
    if (this.channel) this.channel.disconnect()
  }

  onConnected() {
    console.log("[Dashboard] WS connected — requesting charts")
    this.channel.perform("fetch_charts", {
      chart_sources: this.chartsValue,
      stream:        this.streamValue
    })
    console.log("[Dashboard] fetch_charts action sent to server")
    this.startHeartbeat()
  }

  onReceived(data) {
    console.log("[Dashboard] Raw message received:", data)

    if (data.type === "chart_data") {
      console.log(`[Dashboard] Received chart data for ${data.chart_id}`)
      this.renderChart(data.chart_id, data.payload)
    }

    if (data.type === "error") {
      console.error(`[Dashboard] Error for ${data.chart_id}: ${data.message}`)
      this.showError(data.chart_id)
    }
  }

  renderChart(chartId, payload) {
    console.log(`[Dashboard] Rendering chart ${chartId} (type: ${payload.chart_type})`)
    const skeleton  = document.getElementById(`skeleton_${chartId}`)
    const container = document.getElementById(chartId)
    const badge     = document.getElementById(`badge_${chartId}`)

    if (!container) {
      console.warn(`[Dashboard] No container found for ${chartId}`)
      return
    }

    // Hide skeleton, show chart container
    if (skeleton)  skeleton.style.display  = "none"
    container.style.display = "block"
    if (badge) {
      badge.className   = "badge bg-success"
      badge.textContent = "Loaded"
    }

    // Dispatch custom event — chart_controller listens for this
    container.dispatchEvent(new CustomEvent("chart:load", { detail: payload, bubbles: false }))
  }

  showError(chartId) {
    const skeleton = document.getElementById(`skeleton_${chartId}`)
    const badge    = document.getElementById(`badge_${chartId}`)
    if (skeleton) skeleton.innerHTML = '<div class="text-danger text-center pt-5">Failed to load</div>'
    if (badge) { badge.className = "badge bg-danger"; badge.textContent = "Error" }
  }

  startHeartbeat() {
    // Send a heartbeat every 5s so the server knows the client is still alive
    this.heartbeatTimer = setInterval(() => {
      console.log("[Dashboard] Sending heartbeat")
      this.channel.perform("heartbeat", {})
    }, 5000)
  }

  stopHeartbeat() {
    if (this.heartbeatTimer) {
      clearInterval(this.heartbeatTimer)
      this.heartbeatTimer = null
      console.log("[Dashboard] Heartbeat stopped")
    }
  }
}
