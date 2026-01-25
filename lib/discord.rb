# frozen_string_literal: true

require_relative './fanza'
require_relative './logger'

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
    if update.price_4k_change?
      fields << { name: '4K価格', value: "#{update.before.price_4k}円 -> #{update.after.price_4k}円" }
    end
    if update.price_hd_change?
      fields << { name: 'HD価格', value: "#{update.before.price_hd}円 -> #{update.after.price_hd}円" }
    end
    if update.price_dl_change?
      fields << { name: 'DL価格', value: "#{update.before.price_dl}円 -> #{update.after.price_dl}円" }
    end
    if update.price_st_change?
      fields << { name: '配信価格', value: "#{update.before.price_st}円 -> #{update.after.price_st}円" }
    end
    sales_info_text =
      if update.sales_info_change?
        "#{update.before.sales_info} -> #{update.after.sales_info}"
      else
        update.after.sales_info || ''
      end
    fields << { name: 'セールス情報', value: sales_info_text }
    release_status_text =
      if update.release_status_change?
        "#{update.before.release_status} -> #{update.after.release_status}"
      else
        update.after.release_status || ''
      end
    fields << { name: 'リリース時期', value: release_status_text }

    { title: update.after.title,
      url: Fanza.url_video(update.after.cid),
      fields: fields }
  end
end
