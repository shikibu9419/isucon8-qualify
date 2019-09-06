require 'json'

data = open 'output.json' do |file|
  JSON.load(file)
end

puts JSON.pretty_generate data['get_events']
