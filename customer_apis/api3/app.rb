require 'sinatra'
require 'sinatra/json'
require 'sqlite3'
require 'json'

set :port, 4003
set :bind, '0.0.0.0'

def db
  @db ||= begin
    database = SQLite3::Database.new('api3.db')
    database.results_as_hash = true
    database
  end
end

def seed!
  db.execute <<-SQL
    CREATE TABLE IF NOT EXISTS customers (
      id INTEGER PRIMARY KEY,
      week TEXT,
      new_customers INTEGER,
      churned INTEGER
    );
  SQL
  count = db.execute("SELECT COUNT(*) as c FROM customers")[0]['c']
  if count == 0
    data = [
      ['W1', 120, 15], ['W2', 145, 12], ['W3', 132, 18],
      ['W4', 160, 10], ['W5', 178, 22], ['W6', 155, 19],
      ['W7', 190, 14], ['W8', 210, 11]
    ]
    data.each { |row| db.execute("INSERT INTO customers (week, new_customers, churned) VALUES (?, ?, ?)", row) }
  end
end

seed!

get '/chart' do
  # sleep(rand(2.0..5.0))
  rows = db.execute("SELECT * FROM customers ORDER BY id")
  json({
    chart_type: 'area',
    title: 'Customer Acquisition vs Churn',
    xAxis: rows.map { |r| r['week'] },
    series: [
      { name: 'New Customers', data: rows.map { |r| r['new_customers'] } },
      { name: 'Churned',       data: rows.map { |r| r['churned'] } }
    ]
  })
end
