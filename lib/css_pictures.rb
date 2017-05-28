require 'base64'
require 'css_parser'
require 'securerandom'

require 'uri_helper'

class CSSPictures
  include UriHelper

  URL_REGEX = /url\(["']?(?<img>[^"'\)]+)/
  BASE64_REGEX = /data:(?<type>[^\/]+)\/(?<ext>[^;]+);base64,(?<base64>.+)/

  attr_reader :source, :parser, :download_manager

  def initialize(source:, parser: CssParser::Parser.new, download_manager:)
    @source = source
    @parser = parser
    @download_manager = download_manager
    parser.load_uri!(source)
  end

  def process
    images.each do |url|
      process_one(url)
    end
  end

  private

  def process_one(url)
    match = BASE64_REGEX.match(url)
    if match
      dump_base64(match)
    else
      uri = normalize_url(source, url)
      download_manager.enqueue(uri)
    end
  end

  def dump_base64(match)
    file_name = "#{data_dir}/base64_pic-#{SecureRandom.hex(4)}.#{match[:ext]}"
    data = Base64.decode64(match[:base64])
    File.binwrite(file_name, data)
  end

  def images
    result = []
    parser.each_rule_set(:all) do |rule_set, _media_types|
      rule_set.each_declaration do |property, value, _is_important|
        if property =~ /^background(?:-image)?$/ && value.start_with?('url')
          md = URL_REGEX.match(value)
          img = md[:img]
          result << img if img
        end
      end
    end
    result
  end

  def data_dir
    download_manager.data_dir
  end
end
