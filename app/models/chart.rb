class Chart
  include Mongoid::Document
  include Mongoid::Timestamps
  field :dashboard_id, type: String
  field :title, type: String
  field :chart_type, type: String
  field :api_url, type: String
  field :position, type: Integer
end
