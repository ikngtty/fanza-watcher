# frozen_string_literal: true

class Discord
  def post_video_updates(updates)
    webhook_url = URI.parse(ENV['WEBHOOK_URL'])
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
      raise "bad response: #{response.inspect}" if response.code != '204'
    end
  end

  private

  def create_embed_of_video_update(update)
    fields = []
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
    if update.sales_info_change?
      fields << { name: 'セールス情報', value: "#{update.before.sales_info} -> #{update.after.sales_info}" }
    end
    if update.additional_info_change?
      fields << { name: '付加情報', value: "#{update.before.additional_info} -> #{update.after.additional_info}" }
    end
    { title: update.after.title,
      url: update.after.url,
      fields: fields }
  end
end
