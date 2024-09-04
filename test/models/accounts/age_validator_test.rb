# frozen_string_literal: true

require "test_helper"

module Accounts
  class AgeValidatorTest < ActiveSupport::TestCase
    test "when valid age is provided, it returns true" do
      age = 100
      validator = AgeValidator.new(age)

      assert validator.valid?
    end
    test "when invalid age is provided, it returns false" do
      age = 10
      validator = AgeValidator.new(age)

      assert_not validator.valid?
    end
  end
end
