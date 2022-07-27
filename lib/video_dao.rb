# frozen_string_literal: true

require_relative './video'

class VideoDao
  def all
    Video.all
  end

  def fetch(cid)
    Video.find(cid)
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def add(video)
    video.save
  end

  def update(video)
    Video.update(video.cid,
                 title: video.title,
                 sales_info: video.sales_info,
                 additional_info: video.additional_info,
                 price_4k: video.price_4k,
                 price_hd: video.price_hd,
                 price_dl: video.price_dl,
                 price_st: video.price_st)
  end
end
