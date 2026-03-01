// Shared AnyCable cable instance — imported by dashboard_controller.js and application.js
// URL is read from <meta name="action-cable-url"> set by action_cable_meta_tag in the layout
import { createCable } from "@anycable/web"

export default createCable()
