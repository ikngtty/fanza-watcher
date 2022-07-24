# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
require 'thor'

class CLI < Thor
  desc 'add cid', 'add a video to watch'
  def add(cid)
    uri = URI.parse("https://www.dmm.co.jp/digital/videoa/-/detail/=/cid=#{cid}/")
    html = uri.open('Cookie' => 'age_check_done=1')
    doc = Nokogiri::HTML5(html)
    puts doc.at_css('.hreview').inner_text
  end
end

CLI.start(ARGV)
