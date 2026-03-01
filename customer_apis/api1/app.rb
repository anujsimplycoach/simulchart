require 'sinatra'
require 'sinatra/json'
require 'sqlite3'
require 'json'

set :port, 4001
set :bind, '0.0.0.0'

def db
  @db ||= begin
    database = SQLite3::Database.new('api1.db')
    database.results_as_hash = true
    database
  end
end

def seed!
  db.execute <<-SQL
    CREATE TABLE IF NOT EXISTS sales (
      id INTEGER PRIMARY KEY,
      month TEXT,
      revenue REAL,
      year INTEGER
    );
  SQL
  count = db.execute("SELECT COUNT(*) as c FROM sales")[0]['c']
  if count == 0
    data = [
      ['Jan', 12000, 2024], ['Feb', 15000, 2024], ['Mar', 18000, 2024],
      ['Apr', 14000, 2024], ['May', 21000, 2024], ['Jun', 19000, 2024],
      ['Jul', 23000, 2024], ['Aug', 25000, 2024], ['Sep', 20000, 2024],
      ['Oct', 22000, 2024], ['Nov', 28000, 2024], ['Dec', 31000, 2024]
    ]
    data.each { |row| db.execute("INSERT INTO sales (month, revenue, year) VALUES (?, ?, ?)", row) }
  end
end

seed!

get '/chart' do
  # sleep(rand(2.0..5.0))
  rows = db.execute("SELECT month, revenue FROM sales WHERE year = ? ORDER BY id", [params[:year] || 2024])
  json({
    chart_type: 'line',
    title: 'Monthly Sales Revenue',
    xAxis: rows.map { |r| r['month'] },
    series: [{ name: 'Revenue', data: rows.map { |r| r['revenue'] } }]
  })
end
