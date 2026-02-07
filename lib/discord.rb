# frozen_string_literal: true

require_relative './fanza'
require_relative './logger'
require_relative './util'
require_relative './video'

class Discord
  def post_video_updates(updates)
    webhook_url = URI.parse(ENV['DISCORD_WEBHOOK_URL'])
    updates.each_slice(10) do |update_bundle|
      params = {
        username: 'Fanza Watcher',
        embeds: update_bundle.map do |update|
                  create_embed_of_video_update(update)
                end
      }
      http = Net::HTTP.new(webhook_url.host, webhook_url.port)
      http.use_ssl = true
      response = http.post(webhook_url.path,
                           params.to_json,
                           { 'Content-Type' => 'application/json' })
      begin
        response.value
      rescue Net::HTTPExceptions => e
        Logger.error("Discord response: #{response.body}")
        raise e
      end
    end
  end

  private

  def create_embed_of_video_update(update)
    fields = []
    fields << { name: 'タイトル', value: "#{update.before.title} -> #{update.after.title}" } if update.title_change?
    Video::PRICE_TAGS.each do |tag|
      if update.price_change?(tag)
        fields << { name: "#{label_for_price_tag(tag)}価格",
                    value: "#{update.before.prices[tag]}円 -> #{update.after.prices[tag]}円" }
      end
    end
    sales_info_text =
      if update.sales_info_change?
        "#{Video.enclose(update.before.sales_info)} -> #{Video.enclose(update.after.sales_info)}"
      else
        Video.enclose(update.after.sales_info) || ''
      end
    fields << { name: 'セールス情報', value: sales_info_text }
    release_status_text =
      if update.release_status_change?
        "#{Video.enclose(update.before.release_status&.label)} -> #{Video.enclose(update.after.release_status&.label)}"
      else
        Video.enclose(update.after.release_status&.label) || ''
      end
    fields << { name: 'リリース時期', value: release_status_text }

    embed = { title: update.after.title,
              url: Fanza.url_video(update.after.cid),
              fields: fields }
    if video_update_is_hot?(update)
      embed['color'] = 0xff6666
    elsif update.whole_price_change == :down
      embed['color'] = 0xffff66
    end

    embed
  end

  def video_update_is_hot?(update)
    Util.any?(update.after.sales_info) && update.after.release_status <= ReleaseStatus::SEMI_NEW_RELEASE
  end

  def label_for_price_tag(tag)
    case tag
    when :'4k'
      '4K'
    when :hd
      'HD'
    when :dl
      'DL'
    when :st
      '配信'
    else
      raise "unexpected price tag: #{tag}"
    end
  end
end
