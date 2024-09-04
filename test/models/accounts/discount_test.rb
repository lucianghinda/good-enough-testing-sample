# frozen_string_literal: true

require "test_helper"

module Accounts
  class DiscountTest < ActiveSupport::TestCase
    setup do
      @account = Account.create!(name: "Booking owner")
      @discount = Accounts::Discount.new(@account)
    end

    test "account is eligible for discount when all criteria are met" do
      @account.update(created_at: (Accounts::Discount::AGE_CRITERIA_IN_DAYS + 1).days.ago)
      create_confirmed_bookings(
        Accounts::Discount::BOOKINGS_COUNT_CRITERIA + 1,
        total_duration: (Accounts::Discount::DURATION_CRITERIA_IN_HOURS + 1).hours
      )

      result = @discount.eligible_for_discount?

      assert result.success?
    end

    test "account is not eligible for discount when account age criteria is not met" do
      @account.update(created_at: Accounts::Discount::AGE_CRITERIA_IN_DAYS.days.ago)
      create_confirmed_bookings(
        Accounts::Discount::BOOKINGS_COUNT_CRITERIA + 1,
        total_duration: (Accounts::Discount::DURATION_CRITERIA_IN_HOURS + 1).hours
      )

      result = @discount.eligible_for_discount?

      assert result.failure?
      assert_includes result.error_messages, :account_age_below_criteria
    end

    test "account is not eligible for discount when bookings count criteria is not met" do
      @account.update(created_at: (Accounts::Discount::AGE_CRITERIA_IN_DAYS + 1).days.ago)
      create_confirmed_bookings(
        Accounts::Discount::BOOKINGS_COUNT_CRITERIA,
        total_duration: (Accounts::Discount::DURATION_CRITERIA_IN_HOURS + 1).hours
      )

      result = @discount.eligible_for_discount?

      assert result.failure?
      assert_includes result.error_messages, :bookings_count_below_criteria
    end

    test "account is not eligible for discount when duration criteria is not met" do
      @account.update(created_at: (Accounts::Discount::AGE_CRITERIA_IN_DAYS + 1).days.ago)
      create_confirmed_bookings(
        Accounts::Discount::BOOKINGS_COUNT_CRITERIA + 1,
        total_duration: Accounts::Discount::DURATION_CRITERIA_IN_HOURS.hours
      )

      result = @discount.eligible_for_discount?

      assert result.failure?
      assert_includes result.error_messages, :duration_below_criteria
    end

    test "only confirmed bookings are considered for eligibility" do
      @account.update(created_at: (Accounts::Discount::AGE_CRITERIA_IN_DAYS + 1).days.ago)
      create_confirmed_bookings(
        Accounts::Discount::BOOKINGS_COUNT_CRITERIA + 1,
        total_duration: (Accounts::Discount::DURATION_CRITERIA_IN_HOURS + 1).hours
      )
      create_bookings(5, status: "pending", total_duration: 50.hours)

      result = @discount.eligible_for_discount?

      assert result.success?
    end

    test "account is not eligible when confirmed bookings do not meet criteria" do
      @account.update(created_at: (Accounts::Discount::AGE_CRITERIA_IN_DAYS + 1).days.ago)
      create_confirmed_bookings(
        Accounts::Discount::BOOKINGS_COUNT_CRITERIA,
        total_duration: Accounts::Discount::DURATION_CRITERIA_IN_HOURS.hours
      )
      create_bookings(5, status: "pending", total_duration: 50.hours)

      result = @discount.eligible_for_discount?

      assert result.failure?
      assert_includes result.error_messages, :bookings_count_below_criteria
    end

    test "account is not eligible when age is exactly at the criteria" do
      @account.update(created_at: Accounts::Discount::AGE_CRITERIA_IN_DAYS.days.ago)
      create_confirmed_bookings(
        Accounts::Discount::BOOKINGS_COUNT_CRITERIA + 1,
        total_duration: (Accounts::Discount::DURATION_CRITERIA_IN_HOURS + 1).hours
      )

      result = @discount.eligible_for_discount?

      assert result.failure?
      assert_includes result.error_messages, :account_age_below_criteria
    end

    test "account is eligible when age is just over the criteria" do
      @account.update(created_at: (Accounts::Discount::AGE_CRITERIA_IN_DAYS + 1).days.ago)
      create_confirmed_bookings(
        Accounts::Discount::BOOKINGS_COUNT_CRITERIA + 1,
        total_duration: (Accounts::Discount::DURATION_CRITERIA_IN_HOURS + 1).hours
      )

      result = @discount.eligible_for_discount?

      assert result.success?
    end

    test "account is not eligible when bookings count is exactly at the criteria" do
      @account.update(created_at: (Accounts::Discount::AGE_CRITERIA_IN_DAYS + 1).days.ago)
      create_confirmed_bookings(
        Accounts::Discount::BOOKINGS_COUNT_CRITERIA,
        total_duration: (Accounts::Discount::DURATION_CRITERIA_IN_HOURS + 1).hours
      )

      result = @discount.eligible_for_discount?

      assert result.failure?
      assert_includes result.error_messages, :bookings_count_below_criteria
    end

    test "account is eligible when bookings count is just over the criteria" do
      @account.update(created_at: (Accounts::Discount::AGE_CRITERIA_IN_DAYS + 1).days.ago)
      create_confirmed_bookings(
        Accounts::Discount::BOOKINGS_COUNT_CRITERIA + 1,
        total_duration: (Accounts::Discount::DURATION_CRITERIA_IN_HOURS + 1).hours
      )

      result = @discount.eligible_for_discount?

      assert result.success?
    end

    test "account is not eligible when duration is exactly at the criteria" do
      @account.update(created_at: (Accounts::Discount::AGE_CRITERIA_IN_DAYS + 1).days.ago)
      create_confirmed_bookings(
        Accounts::Discount::BOOKINGS_COUNT_CRITERIA + 1,
        total_duration: Accounts::Discount::DURATION_CRITERIA_IN_HOURS.hours
      )

      result = @discount.eligible_for_discount?

      assert result.failure?
      assert_includes result.error_messages, :duration_below_criteria
    end

    test "account is eligible when duration is just over the criteria" do
      @account.update(created_at: (Accounts::Discount::AGE_CRITERIA_IN_DAYS + 1).days.ago)
      create_confirmed_bookings(
        Accounts::Discount::BOOKINGS_COUNT_CRITERIA + 1,
        total_duration: (Accounts::Discount::DURATION_CRITERIA_IN_HOURS + 1).hours
      )

      result = @discount.eligible_for_discount?

      assert result.success?
    end

    private

    def create_confirmed_bookings(count, total_duration:)
      create_bookings(count, status: "confirmed", total_duration: total_duration)
    end

    def create_bookings(count, status:, total_duration:)
      duration_per_booking = (total_duration.to_f / count).ceil

      count.times do |t|
        @account.bookings.create!(
          title: "Booking title #{t}",
          start_time: Time.current,
          end_time: Time.current + duration_per_booking,
          status: status
        )
      end
    end
  end
end
