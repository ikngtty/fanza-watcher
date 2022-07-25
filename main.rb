# frozen_string_literal: true

require 'active_record'
require 'thor'

require_relative './lib/fanza'
require_relative './lib/video'

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
end

def try_find(collection, key)
  collection.find(key)
rescue ActiveRecord::RecordNotFound
  nil
end

CLI.start(ARGV)
