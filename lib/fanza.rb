# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'

require_relative './video'

class Fanza
  def fetch_video(cid)
    video = Video.new
    video.cid = cid

    uri = URI.parse("https://www.dmm.co.jp/digital/videoa/-/detail/=/cid=#{cid}/")
    begin
      html = uri.open('Cookie' => 'age_check_done=1')
    rescue OpenURI::HTTPError
      return video
    end
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

  private

  def get_price_from_text(text)
    text.strip.delete_suffix('円').delete(',').to_i
  end
end
