require 'sinatra'
require 'sinatra/json'
require 'sqlite3'
require 'json'

set :port, 4002
set :bind, '0.0.0.0'

def db
  @db ||= begin
    database = SQLite3::Database.new('api2.db')
    database.results_as_hash = true
    database
  end
end

def seed!
  db.execute <<-SQL
    CREATE TABLE IF NOT EXISTS category_sales (
      id INTEGER PRIMARY KEY,
      category TEXT,
      q1 REAL, q2 REAL, q3 REAL, q4 REAL
    );
  SQL
  count = db.execute("SELECT COUNT(*) as c FROM category_sales")[0]['c']
  if count == 0
    data = [
      ['Electronics', 45000, 52000, 61000, 78000],
      ['Clothing',    23000, 19000, 25000, 42000],
      ['Food',        31000, 33000, 30000, 35000],
      ['Sports',      12000, 18000, 22000, 17000],
      ['Books',        8000,  9000,  7500,  11000]
    ]
    data.each { |row| db.execute("INSERT INTO category_sales (category, q1, q2, q3, q4) VALUES (?, ?, ?, ?, ?)", row) }
  end
end

seed!

get '/chart' do
  # sleep(rand(2.0..5.0))
  rows = db.execute("SELECT * FROM category_sales")
  json({
    chart_type: 'bar',
    title: 'Category Sales by Quarter',
    xAxis: ['Q1', 'Q2', 'Q3', 'Q4'],
    series: rows.map { |r|
      { name: r['category'], data: [r['q1'], r['q2'], r['q3'], r['q4']] }
    }
  })
end
