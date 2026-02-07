# frozen_string_literal: true

require 'json'

require_relative 'release_status'

class Video
  attr_accessor :cid, :title, :sales_info, :release_status, :prices

  PRICE_TAGS = %i[4k hd dl st].freeze

  class << self
    def enclose(text)
      return text if text.nil? || text.empty?

      "【#{text}】"
    end

    def json_create(object)
      video = Video.new
      video.cid = object['cid']
      video.title = object['title']
      video.sales_info = object['sales_info']
      video.release_status = ReleaseStatus.from_label!(object['release_status'])
      video.prices = object['prices'].transform_keys(&:to_sym)
      video
    end
  end

  def as_json(*)
    {
      JSON.create_id => self.class.name,
      cid: cid,
      title: title,
      sales_info: sales_info,
      release_status: release_status.label,
      prices: prices
    }
  end

  def to_json(*)
    as_json.to_json
  end

  def to_s
    sales_info_text = self.class.enclose(sales_info)
    release_status_text = self.class.enclose(release_status.label)
    prices_text = PRICE_TAGS.filter_map { |tag| "#{tag}:#{prices[tag]}" if prices[tag] }.join(',')
    "#{cid} #{sales_info_text}#{release_status_text}#{title} #{prices_text}"
  end
end
