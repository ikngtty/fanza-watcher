# frozen_string_literal: true

require 'active_record'

class Video < ActiveRecord::Base
  self.primary_key = :cid
end
