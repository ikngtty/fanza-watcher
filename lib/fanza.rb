# frozen_string_literal: true

require 'nokogiri'

require_relative './video'

class Fanza
  def fetch_video(browser_context, cid)
    video = Video.new
    video.cid = cid

    browser_context.add_cookies([
      {
        url: 'https://video.dmm.co.jp',
        name: 'age_check_done',
        value: '1'
      }
    ])

    page = browser_context.new_page
    page.goto("https://video.dmm.co.jp/av/content/?id=#{cid}")
    html = page.content
    page.close

    doc = Nokogiri::HTML5(html)

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

    [
      ['price_4k=', '無期限', '4K版ダウンロード ＋4K版ストリーミング'],
      ['price_hd=', '無期限', 'HD版ダウンロード ＋HD版ストリーミング'],
      ['price_dl=', '無期限', 'ダウンロード ＋ストリーミング'],
      ['price_st=', '7日間', 'ストリーミング'],
      ['price_st=', '7日間', 'HD版ストリーミング'], # HACK: `price_st` doubled.
      # HACK: For VR, price attributes differ from text.
      ['price_4k=', '無期限', '8KVR版ダウンロード ＋8KVR版ストリーミング'],
      ['price_hd=', '無期限', 'HQ版ダウンロード ＋HQ版ストリーミング'],
      # ['price_dl=', '無期限', 'ダウンロード ＋ストリーミング'],
      ['price_st=', '7日間', 'HQ版ダウンロード ＋HQ版ストリーミング']
    ].each do |setter, valid_period, label|
      price_area = doc.at_xpath('//label[' +
        "div[p[.=\"#{label}\"]]" +
        'and div[' +
        "p[text()=\"#{valid_period}\"]" +
        'and div[div[p[contains(., "円")]]]' +
        ']' +
        ']')
      next unless price_area

      price_dom = assert_one_dom(
        price_area.xpath('.//p[contains(., "円") and not(contains(@class, "line-through"))]'),
        'price'
      )
      price = get_price_from_text(price_dom.content)
      video.send(setter, price)
    end

    video
  end

  private

  def get_price_from_text(text)
    text.strip.delete_suffix('円').delete(',').to_i
  end

  def assert_one_dom(doms, dom_kind)
      raise "cannot specify the DOM of #{dom_kind}: #{doms}" unless doms.length == 1
      doms.first
  end
end
