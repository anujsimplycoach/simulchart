class Dashboard
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,    type: String
  field :user_id, type: String

  belongs_to :user, optional: true
  validates :name, presence: true

  # Generate N chart sources — points to our 5 Sinatra APIs in round-robin
  SINATRA_APIS = [
    { api_url: 'http://localhost:4001/chart', chart_type: 'line'   },
    { api_url: 'http://localhost:4002/chart', chart_type: 'bar'    },
    { api_url: 'http://localhost:4003/chart', chart_type: 'area'   },
    { api_url: 'http://localhost:4004/chart', chart_type: 'pie'    },
    { api_url: 'http://localhost:4005/chart', chart_type: 'spline' },
  ].freeze

  def self.chart_sources(count: 10)
    count.times.map do |i|
      api = SINATRA_APIS[i % SINATRA_APIS.length]
      {
        id:         "chart_#{i + 1}",
        title:      "Chart #{i + 1} — #{api[:chart_type].capitalize}",
        api_url:    api[:api_url],
        chart_type: api[:chart_type],
        position:   i
      }
    end
  end
end
