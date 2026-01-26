# frozen_string_literal: true

require_relative './video'
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

  def release_status_change?
    @before.release_status != @after.release_status
  end

  def price_change?(tag)
    @before.prices[tag] != @after.prices[tag]
  end

  def any_price_change?
    Video::PRICE_TAGS.any? { |tag| price_change?(tag) }
  end

  def price_change(tag)
    before_price = @before.prices[tag]
    after_price = @after.prices[tag]

    return nil if before_price == after_price
    return :other if before_price.nil? || after_price.nil?

    before_price < after_price ? :up : :down
  end

  def whole_price_change
    changes = Video::PRICE_TAGS.map { |tag| price_change(tag) }

    return :other if changes.include?(:up) && changes.include?(:down)
    return :up if changes.include?(:up)
    return :down if changes.include?(:down)
    return :other if changes.include?(:other)

    nil
  end

  def change?
    title_change? || sales_info_change? || release_status_change? || any_price_change?
  end

  def save
    VideoDao.new.update(@after)
  end
end
