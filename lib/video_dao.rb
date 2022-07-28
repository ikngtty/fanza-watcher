# frozen_string_literal: true

require 'google/cloud/firestore'

require_relative './video'

class VideoDao
  def initialize
    credentials = Google::Cloud::Firestore::Credentials.new('config/service-account-file.json')
    @firestore = Google::Cloud::Firestore.new(credentials: credentials)
    @videos = @firestore.collection 'videos'
  end

  def all
    @videos.get.map do |video|
      JSON.parse(video.data.to_json, create_additions: true)
    end
  end

  def fetch(cid)
    object = @videos.doc(cid).get.data
    return nil if object.nil?

    JSON.parse(object.to_json, create_additions: true)
  end

  def add(video)
    @videos.doc(video.cid).set(video.as_json)
  end

  def update(video)
    @videos.doc(video.cid).update(video.as_json)
  end

  def delete(cid)
    @videos.doc(cid).delete
  end
end
