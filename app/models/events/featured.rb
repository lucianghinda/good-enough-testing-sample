# frozen_string_literal: true

module Events
  class Featured
    RECENT_INTERVALS_IN_DAYS = 7.days

    def initialize(event)
      @event = event
    end

    def elibible?
      case
      when account.standard_account?
        high_popularity? && recent? && premium_event?
      when account.premium_account_type?
        high_popularity? || (recent? && premium_event?)
      when account.vip_account?
        true
      else
        false
      end
    end

    private

    attr_reader :event

    def account = event.account

    def high_popularity? = attendees_count > 100

    def recent? = event.created_at >= RECENT_INTERVALS_IN_DAYS.ago

    def premium_event? = event.premium?

    def attendees_count = event.attendees.size
  end
end
