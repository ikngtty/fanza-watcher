# frozen_string_literal: true

require_relative './video'

class VideoUpdate
  def initialize(before, after)
    @before = before
    @after = after
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

  def save
    Video.update(@after.cid,
                 title: @after.title,
                 sales_info: @after.sales_info,
                 additional_info: @after.additional_info,
                 price_4k: @after.price_4k,
                 price_hd: @after.price_hd,
                 price_dl: @after.price_dl,
                 price_st: @after.price_st)
  end

  def to_text
    lines = []
    lines << "4K価格:#{@before.price_4k} -> #{@after.price_4k}" if price_4k_change?
    lines << "HD価格:#{@before.price_hd} -> #{@after.price_hd}" if price_hd_change?
    lines << "DL価格:#{@before.price_dl} -> #{@after.price_dl}" if price_dl_change?
    lines << "配信価格:#{@before.price_st} -> #{@after.price_st}" if price_st_change?
    lines << "セールス情報:#{@before.sales_info} -> #{@after.sales_info}" if sales_info_change?
    lines << "付加情報:#{@before.additional_info} -> #{@after.additional_info}" if additional_info_change?
    lines.join("\n")
  end
end
