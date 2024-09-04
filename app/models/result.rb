# frozen_string_literal: true

class Result
  attr_reader :payload, :error_messages
  def initialize(payload, error_messages: [])
    @payload = payload
    @error_messages = error_messages
  end

  def success?
    raise AbstractMethodError.new(method_name: "success?", object_name: self.class.name)
  end

  def failure?
    raise AbstractMethodError.new(method_name: "error?", object_name: self.class.name)
  end
end

class Result::Success < Result
  def success? = true
  def failure? = false
end

class Result::Failure < Result
  def success? = false
  def failure? = true
end
