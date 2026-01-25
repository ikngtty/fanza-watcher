# frozen_string_literal: true

require 'google/cloud/firestore'

credentials = Google::Cloud::Firestore::Credentials.new('config/service-account-file.json')
firestore = Google::Cloud::Firestore.new(credentials: credentials)
videos = firestore.collection 'videos'

videos.get.each do |video|
  price_4k = video[:price_4k]
  price_hd = video[:price_hd]
  price_dl = video[:price_dl]
  price_st = video[:price_st]

  prices = {}
  prices[:'4k'] = price_4k if price_4k
  prices[:hd] = price_hd if price_hd
  prices[:dl] = price_dl if price_dl
  prices[:st] = price_st if price_st

  video.ref.update({
                     prices: prices,
                     price_4k: firestore.field_delete,
                     price_hd: firestore.field_delete,
                     price_dl: firestore.field_delete,
                     price_st: firestore.field_delete
                   })
end
