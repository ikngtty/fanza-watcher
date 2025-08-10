# frozen_string_literal: true

require 'nokogiri'

require_relative './logger'
require_relative './video'

class Fanza
  HOST_URL = 'https://video.dmm.co.jp'

  def fetch_video(browser_page, cid)
    video = Video.new
    video.cid = cid

    doc = get_video_page_root_node(browser_page, cid)

    # NOTE: Duplicate the node to cut children.
    title_dom = assert_one_dom(doc.xpath('//span[parent::h1]'), 'title').dup

    sales_info_doms = title_dom.css('span.text-red-600')
    if sales_info_doms.any?
      sales_info_dom = assert_one_dom(sales_info_doms, 'sales info')
      video.sales_info = sales_info_dom.content
      sales_info_dom.unlink
    end

    additional_info_doms = title_dom.css('span.text-red-900')
    if additional_info_doms.any?
      additional_info_dom = assert_one_dom(additional_info_doms, 'additional info')
      video.additional_info = additional_info_dom.content
      additional_info_dom.unlink
    end

    video.title = title_dom.content

    doc.xpath("//label[starts-with(@for, \"#{cid}\")]").each do |radio_label|
      suffix = radio_label['for'].delete_prefix(cid)

      price_doms =
        radio_label.children[1].children[1].child.
          xpath('.//p[contains(., "円") and not(contains(@class, "line-through"))]')
      price_dom = assert_one_dom(price_doms, 'price')
      price = get_price_from_text(price_dom.content)

      setter = video_price_setter_for_id_suffix(suffix)
      video.send(setter, price)
    end

    Logger.info("Scraped Video: #{video}")
    video
  end

  def inspect_video_page_price_id(browser_page, cid)
    doc = get_video_page_root_node(browser_page, cid)

    doc.xpath("//label[starts-with(@for, \"#{cid}\")]").each do |radio_label|
      suffix = radio_label['for'].delete_prefix(cid)
      valid_period = radio_label.children[1].child.content
      label = radio_label.child.children[1].content
      puts "suffix: #{suffix}, valid_period: #{valid_period}, label: #{label}"
    end
  end

  private

  def url_video(cid)
    "#{HOST_URL}/av/content/?id=#{cid}"
  end

  def video_price_setter_for_id_suffix(suffix)
    case suffix
    when '', 'rp' # HACK: Quality is normal or HD(HQ). 'rp' is 7days DL, not streaming only.
      'price_st='
    when 'dl'
      'price_dl='
    when 'dl6'  #HACK: HD for 2D but HQ for VR.
      'price_hd='
    when 'dl7', 'dl8' # HACK: 'dl8' is VR8K, not 4K.
      'price_4k='
    else
      raise "unexpected id suffix: #{suffix}"
    end
  end

  def get_video_page_root_node(browser_page, cid)
    browser_page.context.add_cookies([
      {
        url: HOST_URL,
        name: 'age_check_done',
        value: '1'
      }
    ])

    url = url_video(cid)
    Logger.info("Visiting #{url}")
    browser_page.goto(url)
    Logger.info("Visited #{url}")
    html = browser_page.content
    # Logger.info("Got HTML: #{html}")

    Nokogiri::HTML5(html)
  end

  def get_price_from_text(text)
    text.strip.delete_suffix('円').delete(',').to_i
  end

  def assert_one_dom(doms, dom_kind)
      raise "cannot specify the DOM of #{dom_kind}: #{doms}" unless doms.length == 1
      doms.first
  end
end
