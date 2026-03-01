require 'net/http'
require 'json'

class ChartDataJob < ApplicationJob
  queue_as :default

  def perform(chart_sources, stream)
    Rails.logger.info "[ChartDataJob] Starting #{chart_sources.length} chart fetches for #{stream}"

    threads = chart_sources.map do |chart|
      Thread.new do
        fetch_and_broadcast(chart, stream)
      end
    end

    # Monitor thread: polls Redis every 2s and kills all worker threads if client is gone
    monitor = Thread.new do
      until threads.all? { |t| !t.alive? }
        unless client_alive?(stream)
          Rails.logger.info "[ChartDataJob] Client gone — aborting #{threads.count(&:alive?)} active threads for #{stream}"
          threads.each { |t| t.raise(Interrupt, "client disconnected") if t.alive? }
          break
        end
        sleep 1
      end
    end

    threads.each(&:join)
    monitor.kill if monitor.alive?

    Rails.logger.info "[ChartDataJob] All threads done for #{stream}"
  end

  private

  def client_alive?(stream)
    redis.exists?("dashboard:alive:#{stream}")
  end

  def fetch_and_broadcast(chart, stream)
    chart_id = chart["id"]
    api_url  = chart["api_url"]

    Rails.logger.info "[ChartDataJob] Thread fetching #{chart_id} from #{api_url}"

    uri      = URI.parse(api_url)
    response = Net::HTTP.get_response(uri)
    payload  = JSON.parse(response.body)

    # Check after IO — client may have left while we were fetching
    unless client_alive?(stream)
      Rails.logger.info "[ChartDataJob] #{chart_id} fetched but client gone — skipping broadcast"
      return
    end

    ActionCable.server.broadcast(stream, {
      type:     "chart_data",
      chart_id: chart_id,
      payload:  payload
    })

    Rails.logger.info "[ChartDataJob] Broadcasted #{chart_id}"
  rescue Interrupt
    Rails.logger.info "[ChartDataJob] Thread for #{chart_id} interrupted — client disconnected"
  rescue => e
    Rails.logger.error "[ChartDataJob] Error fetching #{chart_id}: #{e.message}"
    return unless client_alive?(stream)
    ActionCable.server.broadcast(stream, {
      type:     "error",
      chart_id: chart_id,
      message:  e.message
    })
  end

  def redis
    @redis ||= Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379"))
  end
end
