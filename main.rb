# frozen_string_literal: true

require 'active_record'
require 'nokogiri'
require 'open-uri'
require 'thor'

ActiveRecord::Base.establish_connection(
  'adapter' => 'sqlite3',
  'database' => './db/development.sqlite3'
)

class Video < ActiveRecord::Base
  self.primary_key = :cid
end

class CLI < Thor
  desc 'add cid', 'add a video to watch'
  def add(cid)
    if try_find(Video, cid)
      puts 'already added'
      exit 1
    end

    video = fetch_video(cid)
    video.save
  end
end

def fetch_video(cid)
  video = Video.new
  video.cid = cid

  uri = URI.parse("https://www.dmm.co.jp/digital/videoa/-/detail/=/cid=#{cid}/")
  html = uri.open('Cookie' => 'age_check_done=1')
  doc = Nokogiri::HTML5(html)

  hreview = doc.at_css('.hreview')
  video.sales_info = hreview.at_css('.tx-hangaku')&.inner_text
  video.additional_info = hreview.at_css('.red')&.inner_text
  video.title = hreview.at_css('#title').inner_text

  prices = {}
  %w[4k hd dl st].each do |price_kind|
    ptn = doc.at_css("##{price_kind}")
    next unless ptn

    price_area = ptn.next.at_css('.price')
    sales_price = price_area.at_css('.tx-hangaku')&.inner_text
    prices[price_kind] = get_price_from_text(sales_price || price_area.inner_text)
  end
  video.price_4k = prices['4k']
  video.price_hd = prices['hd']
  video.price_dl = prices['dl']
  video.price_st = prices['st']

  video
end

def get_price_from_text(text)
  text.strip.delete_suffix('円').delete(',').to_i
end

def try_find(collection, key)
  collection.find(key)
rescue ActiveRecord::RecordNotFound
  nil
end

CLI.start(ARGV)
