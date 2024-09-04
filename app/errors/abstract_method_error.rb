# frozen_string_literal: true

class AbstractMethodError < StandardError
  def initialize(method_name:, object_name:)
    super("You have to implement the method `#{method_name}` from object `#{object_name}` in a subclass")
  end
end
