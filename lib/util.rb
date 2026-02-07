# frozen_string_literal: true

module Util
  class << self
    def nil_or_empty?(obj)
      obj.nil? || obj.empty?
    end

    def any?(obj)
      !nil_or_empty?(obj)
    end
  end
end
