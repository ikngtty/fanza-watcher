# frozen_string_literal: true

require 'net/http'

require_relative './logger'
require_relative './release_status'
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
        pricing {
          sale {
            name
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
        pricing {
          regularPriceInclusiveTax
          effectivePriceInclusiveTax
        }
        expireDays
      }","variables":{"id":"#{cid}"}}
    GRAPHQL
    # Remove newlines and extra spaces to create valid JSON.
    request_body = request_body.gsub(/\s+/, ' ').strip

    Logger.info("Fetching #{cid}")
    response = http.post(uri.path, request_body, headers)
    Logger.info("Got data: #{response.body}")
    response.value # Raise an error when the response's status code is not success.

    ppv_content = JSON.parse(response.body)['data']['ppvContent'] # TODO: Validate.
    unless ppv_content
      Logger.warn("Not Found for #{cid}")
      return nil
    end

    video = Video.new
    video.cid = cid
    video.title = ppv_content['title']
    video.sales_info = ppv_content.dig('pricing', 'sale', 'name')
    video.release_status = ReleaseStatus.from_value!(ppv_content['releaseStatus'] || '')
    ppv_content['products'].each do |product|
      id_suffix = product['id'].delete_prefix(cid)
      price_tag = video_price_tag_for_id_suffix(id_suffix)
      price = product['pricing']['effectivePriceInclusiveTax'] || product['pricing']['regularPriceInclusiveTax']
      video.prices[price_tag] = price
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

  def video_price_tag_for_id_suffix(suffix)
    case suffix
    when '', 'rp' # HACK: Quality is normal or HD(HQ). 'rp' is 7days DL, not streaming only.
      :st
    when 'dl'
      :dl
    when 'dl6' # HACK: HD for 2D but HQ for VR.
      :hd
    when 'dl7', 'dl8' # HACK: 'dl8' is VR8K, not 4K.
      :'4k'
    else
      raise "unexpected id suffix: #{suffix}"
    end
  end
end
