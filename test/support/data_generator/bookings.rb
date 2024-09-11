# frozen_string_literal: true

module DataGenerator
  class Bookings
    def initialize(account:)
      @account = account
    end

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
