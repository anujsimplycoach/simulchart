require 'sinatra'
require 'sinatra/json'
require 'sqlite3'
require 'json'

set :port, 4005
set :bind, '0.0.0.0'

def db
  @db ||= begin
    database = SQLite3::Database.new('api5.db')
    database.results_as_hash = true
    database
  end
end

def seed!
  db.execute <<-SQL
    CREATE TABLE IF NOT EXISTS server_metrics (
      id INTEGER PRIMARY KEY,
      timestamp TEXT,
      cpu REAL,
      memory REAL,
      latency REAL
    );
  SQL
  count = db.execute("SELECT COUNT(*) as c FROM server_metrics")[0]['c']
  if count == 0
    data = [
      ['00:00', 22, 45, 120], ['02:00', 18, 42, 110], ['04:00', 15, 40, 105],
      ['06:00', 25, 48, 130], ['08:00', 65, 72, 210], ['10:00', 78, 80, 280],
      ['12:00', 82, 85, 310], ['14:00', 75, 78, 260], ['16:00', 80, 82, 290],
      ['18:00', 70, 75, 240], ['20:00', 55, 65, 190], ['22:00', 35, 55, 150]
    ]
    data.each { |row| db.execute("INSERT INTO server_metrics (timestamp, cpu, memory, latency) VALUES (?, ?, ?, ?)", row) }
  end
end

seed!

get '/chart' do
  # sleep(rand(2.0..5.0))
  rows = db.execute("SELECT * FROM server_metrics ORDER BY id")
  json({
    chart_type: 'spline',
    title: 'Server Performance Metrics',
    xAxis: rows.map { |r| r['timestamp'] },
    series: [
      { name: 'CPU %',      data: rows.map { |r| r['cpu'] } },
      { name: 'Memory %',   data: rows.map { |r| r['memory'] } },
      { name: 'Latency ms', data: rows.map { |r| r['latency'] } }
    ]
  })
end
