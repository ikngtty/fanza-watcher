# frozen_string_literal: true

require 'google/cloud/firestore'

credentials = Google::Cloud::Firestore::Credentials.new('config/service-account-file.json')
firestore = Google::Cloud::Firestore.new(credentials: credentials)
videos = firestore.collection 'videos'

def disclose(text)
  return text if text.nil?

  text.delete_prefix('【').delete_suffix('】')
end

videos.get.each do |video|
  sales_info = video[:sales_info]
  release_status = video[:release_status]

  video.ref.update({
                     sales_info: disclose(sales_info),
                     release_status: disclose(release_status)
                   })
end
