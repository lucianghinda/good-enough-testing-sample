# frozen_string_literal: true

module Accounts
  class AgeValidator
    VALID_AGE_RANGE = 18

    def valid?(age)
      coerce(age) >= VALID_AGE_RANGE
    end

    def coerce(age)
      Integer(age).tap do |validated_age|
        if validated_age.negative?
          raise NegativeAgeError, "Age must be a natural number"
        end
      end
    rescue ArgumentError
      raise InvalidAgeError, "Age must be a valid integer"
    end
  end
end
