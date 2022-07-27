# frozen_string_literal: true

class Video
  attr_accessor :cid, :title, :sales_info, :additional_info,
                :price_4k, :price_hd, :price_dl, :price_st

  def url
    "https://www.dmm.co.jp/digital/videoa/-/detail/=/cid=#{cid}/"
  end
end
