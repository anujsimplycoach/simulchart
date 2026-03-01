class DashboardChannel < ApplicationCable::Channel
  HEARTBEAT_TTL = 15 # seconds — JS sends every 5s, so 3 missed = dead

  def subscribed
    stream_from params[:stream]
    mark_alive!
    Rails.logger.info "[DashboardChannel] Subscribed to #{params[:stream]}"
  end

  def unsubscribed
    mark_dead!
    Rails.logger.info "[DashboardChannel] Unsubscribed from #{params[:stream]} — heartbeat key cleared"
  end

  def heartbeat(data)
    mark_alive!
    Rails.logger.debug "[DashboardChannel] Heartbeat received for #{params[:stream]}"
  end

  def fetch_charts(data)
    chart_sources = data["chart_sources"]
    stream        = data["stream"]

    Rails.logger.info "[DashboardChannel] Enqueuing ChartDataJob for #{chart_sources.length} charts on #{stream}"

    ChartDataJob.perform_later(chart_sources, stream)
  end

  private

  def heartbeat_key
    "dashboard:alive:#{params[:stream]}"
  end

  def mark_alive!
    redis.setex(heartbeat_key, HEARTBEAT_TTL, "1")
  end

  def mark_dead!
    redis.del(heartbeat_key)
  end

  def redis
    @redis ||= Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379"))
  end
end
