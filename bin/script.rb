require 'optparse'
require 'pry'
require 'pp'

require 'app'

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: ./bin/script.rb [options]'

  opts.on(:REQUIRED, '-uURL', '--url=URL', 'Site url to downlowd pictures from') do |url|
    options[:url] = url
  end

  opts.on('-dDIR', '--data=DIR', 'Directory pictures will download to') do |data_dir|
    options[:data_dir] = data_dir
  end
end.parse!

app = App.new(options)
app.run

puts 'Done!'
