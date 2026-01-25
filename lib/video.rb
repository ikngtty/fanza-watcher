# frozen_string_literal: true

require 'json'

class Video
  attr_accessor :cid, :title, :sales_info, :release_status,
                :price_4k, :price_hd, :price_dl, :price_st

  def self.json_create(object)
    video = Video.new
    video.cid = object['cid']
    video.title = object['title']
    video.sales_info = object['sales_info']
    video.release_status = object['release_status']
    video.price_4k = object['price_4k']
    video.price_hd = object['price_hd']
    video.price_dl = object['price_dl']
    video.price_st = object['price_st']
    video
  end

  def as_json(*)
    {
      JSON.create_id => self.class.name,
      cid: cid,
      title: title,
      sales_info: sales_info,
      release_status: release_status,
      price_4k: price_4k,
      price_hd: price_hd,
      price_dl: price_dl,
      price_st: price_st
    }
  end

  def to_json(*)
    as_json.to_json
  end

  def to_s
    "#{cid} #{sales_info}#{release_status}#{title} " \
    "#{price_4k},#{price_hd},#{price_dl},#{price_st}"
  end
end
