# frozen_string_literal: true

require_relative './video_dao'

class VideoUpdate
  attr_reader :before, :after

  def initialize(before, after)
    @before = before
    @after = after
  end

  def title_change?
    @before.title != @after.title
  end

  def sales_info_change?
    @before.sales_info != @after.sales_info
  end

  def additional_info_change?
    @before.additional_info != @after.additional_info
  end

  def price_4k_change?
    @before.price_4k != @after.price_4k
  end

  def price_hd_change?
    @before.price_hd != @after.price_hd
  end

  def price_dl_change?
    @before.price_dl != @after.price_dl
  end

  def price_st_change?
    @before.price_st != @after.price_st
  end

  def price_change?
    price_4k_change? || price_hd_change? || price_dl_change? || price_st_change?
  end

  def change?
    title_change? || sales_info_change? || additional_info_change? || price_change?
  end

  def save
    VideoDao.new.update(@after)
  end
end
