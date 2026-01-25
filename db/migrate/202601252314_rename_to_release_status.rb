# frozen_string_literal: true

require 'google/cloud/firestore'

credentials = Google::Cloud::Firestore::Credentials.new('config/service-account-file.json')
firestore = Google::Cloud::Firestore.new(credentials: credentials)
videos = firestore.collection 'videos'

videos.get.each do |video|
  additional_info = video[:additional_info]
  video.ref.update({
                     release_status: additional_info,
                     additional_info: firestore.field_delete
                   })
end
