require 'pp'
require 'uri'
require 'net/http'
require 'securerandom'
require 'ruby-progressbar'

class DownloadManager
  attr_reader :queue, :data_dir

  def initialize(data_dir:)
    @data_dir = data_dir
    @queue = []
  end

  def enqueue(url)
    queue << url
  end

  def run
    progressbar = ProgressBar.create(title: 'Dowloading...', total: queue.length)
    queue.each do |url|
      download(url)
      progressbar.increment
    end
  end

  private

  def download(url)
    uri = URI(url)
    file_path = "#{data_dir}/#{file_name(uri)}"

    Net::HTTP.start(uri.host, uri.port, use_ssl: 'https' == uri.scheme) do |http|
      request = Net::HTTP::Get.new uri
      response = http.request request
      File.binwrite(file_path, response.body)
    end
  end

  def file_name(uri)
    file_name = File.basename(uri.path)
    file_name = SecureRandom.hex(8) if file_name.empty?
    file_name
  end
end
