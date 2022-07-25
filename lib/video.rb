# frozen_string_literal: true

require 'active_record'

class Video < ActiveRecord::Base
  self.primary_key = :cid

  def url
    "https://www.dmm.co.jp/digital/videoa/-/detail/=/cid=#{cid}/"
  end
end
