require 'sinatra'
require 'sinatra/json'
require 'sqlite3'
require 'json'

set :port, 4004
set :bind, '0.0.0.0'

def db
  @db ||= begin
    database = SQLite3::Database.new('api4.db')
    database.results_as_hash = true
    database
  end
end

def seed!
  db.execute <<-SQL
    CREATE TABLE IF NOT EXISTS market_share (
      id INTEGER PRIMARY KEY,
      company TEXT,
      share REAL
    );
  SQL
  count = db.execute("SELECT COUNT(*) as c FROM market_share")[0]['c']
  if count == 0
    data = [
      ['Our Product', 34.5],
      ['Competitor A', 28.2],
      ['Competitor B', 19.1],
      ['Competitor C', 11.8],
      ['Others', 6.4]
    ]
    data.each { |row| db.execute("INSERT INTO market_share (company, share) VALUES (?, ?)", row) }
  end
end

seed!

get '/chart' do
  # sleep(rand(2.0..5.0))
  rows = db.execute("SELECT company, share FROM market_share")
  json({
    chart_type: 'pie',
    title: 'Market Share Distribution',
    series: [{
      name: 'Market Share',
      data: rows.map { |r| { name: r['company'], y: r['share'] } }
    }]
  })
end
