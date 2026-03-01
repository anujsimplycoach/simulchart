// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo"
import { start } from "@anycable/turbo-stream"
import cable from "channels/consumer"

// Reuse the shared AnyCable cable instance for Turbo Streams
// Prevent frequent resubscriptions during morphing or navigation
start(cable, { delayedUnsubscribe: true })

import "controllers"
import * as bootstrap from "bootstrap"
import "channels"
