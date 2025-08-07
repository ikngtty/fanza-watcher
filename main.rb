# frozen_string_literal: true

require 'thor'

require_relative './lib/discord'
require_relative './lib/fanza'
require_relative './lib/playwright_util'
require_relative './lib/video_dao'
require_relative './lib/video_update'

class CLI < Thor
  desc 'scrape CID', 'Scrape a video (for debug)'
  def scrape(cid)
    PlaywrightUtil.use_browser_page do |browser_page|
      puts Fanza.new.fetch_video(browser_page, cid)
    end
  end

  desc 'add CID', 'Add a video to watch'
  def add(cid)
    video_dao = VideoDao.new
    if video_dao.fetch(cid)
      puts 'already added'
      exit 1
    end

    video = nil
    PlaywrightUtil.use_browser_page do |browser_page|
      video = Fanza.new.fetch_video(browser_page, cid)
    end
    unless video.title
      puts 'failed to fetch'
      exit 1
    end

    video_dao.add(video)
    puts "added: #{video}"
  end

  desc 'update', 'Update videos'
  def update
    updates = nil
    PlaywrightUtil.use_browser_page do |browser_page|
      updates = VideoDao.new.all.map do |video|
        new_video = Fanza.new.fetch_video(browser_page, video.cid)
        sleep 1
        VideoUpdate.new(video, new_video)
      end
    end
    Discord.new.post_video_updates(updates.find_all(&:price_change?))
    updates.find_all(&:change?).each(&:save)
  end

  desc 'remove CID', 'Remove a video'
  def remove(cid)
    dao = VideoDao.new
    video = dao.fetch(cid)
    unless video
      puts 'not found'
      exit 1
    end
    dao.delete(cid)
    puts "removed: #{video}"
  end

  desc 'view', 'View added videos'
  def view
    VideoDao.new.all.each { |video| puts video }
  end
end

CLI.start(ARGV)
