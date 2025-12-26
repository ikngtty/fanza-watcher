# frozen_string_literal: true

require 'net/http'

require_relative './logger'
require_relative './video'

class Fanza
  HOST_URL = 'https://video.dmm.co.jp'

  class << self
    def url_video(cid)
      "#{HOST_URL}/av/content/?id=#{cid}"
    end
  end

  def fetch_video(cid)
    uri = URI.parse('https://api.video.dmm.co.jp/graphql')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    headers = { 'Content-Type' => 'application/json' }

    request_body = <<-GRAPHQL
      {"operationName":"ContentPageData","query":"query ContentPageData($id: ID!) {
        ppvContent(id: $id) {
          ...ContentData
        }
      }
      fragment ContentData on PPVContent {
        id
        title
        releaseStatus
        contentType
        priceSummary {
          campaign {
            title
          }
        }
        products {
          ...ProductData
        }
      }
      fragment ProductData on PPVProduct {
        id
        deliveryUnit {
          id
          priority
          streamMaxQualityGroup
          downloadMaxQualityGroup
        }
        expireDays
        priceInclusiveTax
        sale {
          priceInclusiveTax
        }
      }","variables":{"id":"#{cid}"}}
    GRAPHQL
    # Remove newlines and extra spaces to create valid JSON.
    request_body = request_body.gsub(/\s+/, ' ').strip

    Logger.info("Fetching #{cid}")
    response = http.post(uri.path, request_body, headers)
    response.value # Raise an error when the response's status code is not success.
    Logger.info("Got data: #{response.body}")

    ppvContent = JSON.parse(response.body)['data']['ppvContent'] # TODO: Validate.
    unless ppvContent
      Logger.warn("Not Found for #{cid}")
      return nil
    end

    video = Video.new
    video.cid = cid
    video.title = ppvContent['title']
    video.sales_info = enclose(ppvContent.dig('priceSummary', 'campaign', 'title'))
    video.additional_info = enclose(label_for_release_status(ppvContent['releaseStatus']))
    ppvContent['products'].each do |product|
      id_suffix = product['id'].delete_prefix(cid)
      price_setter = video_price_setter_for_id_suffix(id_suffix)
      price = product['sale'] ? product['sale']['priceInclusiveTax'] : product['priceInclusiveTax']
      video.send(price_setter, price)
    end
    Logger.info("Scraped Video: #{video}")
    video
  end

  private

  def kind_for_quality_group(group)
    case group
    when 'QUALITY_GROUP_SD', 'QUALITY_GROUP_VR_STANDARD'
      'sd'
    when 'QUALITY_GROUP_HD'
      'hd'
    when 'QUALITY_GROUP_4K'
      '4k'
    when 'QUALITY_GROUP_VR_HQ'
      'hq'
    when 'QUALITY_GROUP_VR_8K'
      '8kvr'
    else
      raise "unexpected quality group: #{group}"
    end
  end

  def label_for_release_status(status)
    case status
    when 'COMING_SOON'
      '近日公開'
    when 'PRE_ORDER'
      '予約'
    when 'PRE_RELEASE'
      '先行公開'
    when 'LATEST_RELEASE'
      '最新作'
    when 'NEW_RELEASE'
      '新作'
    when 'SEMI_NEW_RELEASE'
      '準新作'
    when '', nil
      ''
    else
      raise "unexpected release status: #{status}"
    end
  end

  def video_price_setter_for_id_suffix(suffix)
    case suffix
    when '', 'rp' # HACK: Quality is normal or HD(HQ). 'rp' is 7days DL, not streaming only.
      'price_st='
    when 'dl'
      'price_dl='
    when 'dl6' # HACK: HD for 2D but HQ for VR.
      'price_hd='
    when 'dl7', 'dl8' # HACK: 'dl8' is VR8K, not 4K.
      'price_4k='
    else
      raise "unexpected id suffix: #{suffix}"
    end
  end

  def enclose(text)
    return text if text.nil? || text.empty?

    "【#{text}】"
  end
end
