require 'net/http'
require 'nokogiri'
require 'fileutils'

require 'uri_helper'
require 'css_pictures'
require 'download_manager'

class App
  include UriHelper

  attr_reader :url, :data_dir, :download_manager

  def initialize(url:, data_dir: nil)
    @url = url
    @data_dir = data_dir || File.absolute_path(File.expand_path('../../data/', __FILE__))
    @download_manager = DownloadManager.new(data_dir: @data_dir)
    create_data_dir
  end

  def run
    body = Net::HTTP.get(URI(url))
    doc = Nokogiri::HTML(body)
    images_from_css(doc)
    images_from_img_tags(doc)
    download_manager.run
  end

  private

  def create_data_dir
    FileUtils.mkdir_p(data_dir)
  end

  def images_from_css(doc)
    stylesheets = doc.xpath("//link[@rel='stylesheet']/@href").map(&:value)
    stylesheets.each do |css_url|
      source = normalize_url(url, css_url)
      css_pictures = CSSPictures.new(source: source, download_manager: download_manager)
      css_pictures.process
    end
  end

  def images_from_img_tags(doc)
    images = doc.xpath('//img/@src').map(&:value)
    images.each do |img_url|
      source = normalize_url(url, img_url)
      download_manager.enqueue(source)
    end
  end
end
