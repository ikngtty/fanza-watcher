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

    hreview = doc.at_css('.hreview')
    sales_info = hreview.at_css('.tx-hangaku')&.inner_text
    puts sales_info
    additional_info = hreview.at_css('.red')&.inner_text
    puts additional_info
    title = hreview.at_css('#title').inner_text
    puts title

    prices = {}
    %w[4k hd dl st].each do |price_kind|
      ptn = doc.at_css("##{price_kind}")
      next unless ptn

      price_area = ptn.next.at_css('.price')
      sales_price = price_area.at_css('.tx-hangaku')&.inner_text
      prices[price_kind] = get_price_from_text(sales_price || price_area.inner_text)
    end

    p prices
  end
end

def get_price_from_text(text)
  text.strip.delete_suffix('円').delete(',').to_i
end

CLI.start(ARGV)
