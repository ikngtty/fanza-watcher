# frozen_string_literal: true

require 'active_record'
require 'thor'

require_relative './lib/discord'
require_relative './lib/fanza'
require_relative './lib/video'
require_relative './lib/video_update'

ActiveRecord::Base.establish_connection(
  'adapter' => 'sqlite3',
  'database' => './db/development.sqlite3'
)

class CLI < Thor
  desc 'add cid', 'add a video to watch'
  def add(cid)
    if try_find(Video, cid)
      puts 'already added'
      exit 1
    end

    video = Fanza.new.fetch_video(cid)
    video.save
  end

  desc 'update', 'update videos'
  def update
    updates = Video.all.map do |video|
      new_video = Fanza.new.fetch_video(video.cid)
      sleep 1
      VideoUpdate.new(video, new_video)
    end
    Discord.new.post_video_updates(updates.find_all(&:price_change?))
    updates.each(&:save)
  end
end

def try_find(collection, key)
  collection.find(key)
rescue ActiveRecord::RecordNotFound
  nil
end

CLI.start(ARGV)
