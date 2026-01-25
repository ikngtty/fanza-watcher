# frozen_string_literal: true

require 'json'

class Video
  attr_accessor :cid, :title, :sales_info, :release_status, :prices

  PRICE_TAGS = %i[4k hd dl st].freeze

  def self.json_create(object)
    video = Video.new
    video.cid = object['cid']
    video.title = object['title']
    video.sales_info = object['sales_info']
    video.release_status = object['release_status']
    video.prices = object['prices'].transform_keys(&:to_sym)
    video
  end

  def as_json(*)
    {
      JSON.create_id => self.class.name,
      cid: cid,
      title: title,
      sales_info: sales_info,
      release_status: release_status,
      prices: prices
    }
  end

  def to_json(*)
    as_json.to_json
  end

  def to_s
    prices_text = PRICE_TAGS.filter_map { |tag| "#{tag}:#{prices[tag]}" if prices[tag] }.join(',')
    "#{cid} #{sales_info}#{release_status}#{title} #{prices_text}"
  end
end
