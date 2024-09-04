# frozen_string_literal: true

module Accounts
  class Discount
    AGE_CRITERIA_IN_DAYS = 365
    BOOKINGS_COUNT_CRITERIA = 10
    DURATION_CRITERIA_IN_HOURS = 100

    def initialize(account)
      @account = account
      @bookings = nil
      @total_hours = nil
      @errors = []
    end

    def eligible_for_discount?
      verify_age_criteria
      verify_bookings_count_criteria
      verify_duration_criteria

      if @errors.empty?
        Result::Success.new(@account)
      else
        Result::Failure.new(@account, error_messages: @errors)
      end
    end

    private

    attr_reader :account

    def verify_age_criteria
      return true if account_age > AGE_CRITERIA_IN_DAYS

      @errors << :account_age_below_criteria
      false
    end

    def verify_bookings_count_criteria
      return true if bookings.count > BOOKINGS_COUNT_CRITERIA

      @errors << :bookings_count_below_criteria
      false
    end

    def verify_duration_criteria
      return true if total_hours > DURATION_CRITERIA_IN_HOURS

      @errors << :duration_below_criteria
      false
    end

    def total_hours
      @total_hours ||= bookings.sum { |booking| (booking.end_time - booking.start_time) / 1.hour }.to_i
    end

    def account_age
      (Date.current - account.created_at.to_date).to_i
    end

    def bookings
      @bookings ||= account.bookings.where(status: "confirmed")
    end
  end
end
