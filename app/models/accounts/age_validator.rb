# frozen_string_literal: true

module Accounts
  class AgeValidator
    attr_reader :age

    VALID_AGE_RANGE = (18..).freeze

    def initialize(age)
      @age = validate_age(age)
    end

    def valid?
      VALID_AGE_RANGE.cover?(age)
    end

    private

    def validate_age(age)
      Integer(age).tap do |validated_age|
        raise NegativeAgeError, "Age must be a natural number" if validated_age.negative?
      end
    rescue ArgumentError
      raise InvalidAgeError, "Age must be a valid integer"
    end
  end
end
