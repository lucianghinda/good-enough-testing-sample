# frozen_string_literal: true

require "test_helper"

class BookingTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:eternal_account)
    @valid_attributes = {
      account: @account,
      start_time: Time.current + 1.hour,
      end_time: Time.current + 2.hours,
      status: "pending",
      title: "Booking title"
    }
  end

  test "booking is valid with valid attributes" do
    booking = Booking.new(@valid_attributes)
    assert booking.valid?
  end

  test "booking belongs to an account" do
    assert_respond_to Booking.new, :account
  end

  test "booking requires start_time" do
    booking = Booking.new(@valid_attributes.merge(start_time: nil))
    assert_not booking.valid?
    assert_includes booking.errors[:start_time], "can't be blank"
  end

  test "booking requires end_time" do
    booking = Booking.new(@valid_attributes.merge(end_time: nil))
    assert_not booking.valid?
    assert_includes booking.errors[:end_time], "can't be blank"
  end

  test "booking requires title" do
    booking = Booking.new(@valid_attributes.merge(title: nil))
    assert_not booking.valid?
    assert_includes booking.errors[:title], "can't be blank"
  end

  test "booking end_time is after start_time" do
    booking = Booking.new(@valid_attributes.merge(end_time: @valid_attributes[:start_time] - 1.hour))
    assert_not booking.valid?
    assert_includes booking.errors[:end_time], "must be after the start time"
  end

  test "booking has valid status enum values" do
    assert_equal %w[pending confirmed cancelled], Booking.statuses.keys
  end

  test "booking has status methods" do
    booking = Booking.new(@valid_attributes)
    assert_respond_to booking, :status_pending?
    assert_respond_to booking, :status_confirmed?
    assert_respond_to booking, :status_cancelled?
  end

  test "upcoming scope returns future bookings" do
    future_booking = Booking.create!(@valid_attributes)
    past_booking = Booking.create!(@valid_attributes.merge(start_time: Time.current - 2.hours, end_time: Time.current - 1.hour))

    assert_includes Booking.upcoming, future_booking
    assert_not_includes Booking.upcoming, past_booking
  end

  test "past scope returns past bookings" do
    future_booking = Booking.create!(@valid_attributes)
    past_booking = Booking.create!(@valid_attributes.merge(start_time: Time.current - 2.hours, end_time: Time.current - 1.hour))

    assert_includes Booking.past, past_booking
    assert_not_includes Booking.past, future_booking
  end

  test "by_account scope returns bookings for a specific account" do
    booking1 = Booking.create!(@valid_attributes)
    booking2 = Booking.create!(@valid_attributes)
    other_account = accounts(:expirable_account)
    other_booking = Booking.create!(@valid_attributes.merge(account: other_account))

    assert_includes Booking.by_account(@account.id), booking1
    assert_includes Booking.by_account(@account.id), booking2
    assert_not_includes Booking.by_account(@account.id), other_booking
  end
end
