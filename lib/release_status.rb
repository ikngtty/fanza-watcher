# frozen_string_literal: true

class ReleaseStatus
  include Comparable

  attr_reader :value, :label, :order

  def initialize(value, label, order)
    @value = value
    @label = label
    @order = order
  end

  NONE = new('', '', 0).freeze
  SEMI_NEW_RELEASE = new('SEMI_NEW_RELEASE', '準新作', 1).freeze
  NEW_RELEASE = new('NEW_RELEASE', '新作', 2).freeze
  LATEST_RELEASE = new('LATEST_RELEASE', '最新作', 3).freeze
  PRE_RELEASE = new('PRE_RELEASE', '先行公開', 4).freeze
  PRE_ORDER = new('PRE_ORDER', '予約', 5).freeze
  COMING_SOON = new('COMING_SOON', '近日公開', 6).freeze

  private_class_method :new

  ALL = [NONE, SEMI_NEW_RELEASE, NEW_RELEASE, LATEST_RELEASE, PRE_RELEASE, PRE_ORDER, COMING_SOON].freeze

  class << self
    def from_value(value)
      ALL.find { it.value == value }
    end

    def from_value!(value)
      return nil if value.nil?

      from_value(value) || (raise ArgumentError, "unexpected value (given: \"#{value}\")")
    end

    def from_label(label)
      ALL.find { it.label == label }
    end

    def from_label!(label)
      return nil if label.nil?

      from_label(label) || (raise ArgumentError, "unexpected label (given: \"#{label}\")")
    end
  end

  def <=>(other)
    return nil unless other.is_a?(ReleaseStatus)

    order <=> other.order
  end

  def to_s
    "#{order}:#{value}(#{label})"
  end
end
