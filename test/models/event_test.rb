require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "valid event can be saved" do
    account = Account.create!(name: "Test Account")
    event = Event.new(
      account: account,
      title: "Test Event",
      location: "Test Location",
      start_time: Time.current + 1.day,
      end_time: Time.current + 2.days,
      status: "pending"
    )

    assert event.save
    assert event.persisted?
  end

  test "event without required attributes cannot be saved" do
    event = Event.new
    assert_not event.save
    assert_includes event.errors[:account], "must exist"
    assert_includes event.errors[:title], "can't be blank"
    assert_includes event.errors[:location], "can't be blank"
    assert_includes event.errors[:start_time], "can't be blank"
    assert_includes event.errors[:end_time], "can't be blank"
  end

  test "end time must be after start time" do
    account = Account.create!(name: "Test Account")
    event = Event.new(
      account: account,
      title: "Test Event",
      location: "Test Location",
      start_time: Time.current + 2.days,
      end_time: Time.current + 1.day,
      status: "pending"
    )

    assert_not event.save
    assert_includes event.errors[:end_time], "must be after the start time"
  end

  test "status enum works correctly" do
    event = Event.new
    assert_respond_to event, :status_pending?
    assert_respond_to event, :status_confirmed?
    assert_respond_to event, :status_cancelled?
  end

  test "upcoming scope returns only future events" do
    account = Account.create!(name: "Test Account")
    future_event = Event.create!(
      account: account,
      title: "Future Event",
      location: "Test Location",
      start_time: Time.current + 1.day,
      end_time: Time.current + 2.days
    )
    past_event = Event.create!(
      account: account,
      title: "Past Event",
      location: "Test Location",
      start_time: Time.current - 2.days,
      end_time: Time.current - 1.day
    )

    assert_includes Event.upcoming, future_event
    assert_not_includes Event.upcoming, past_event
  end

  test "past scope returns only past events" do
    account = Account.create!(name: "Test Account")
    future_event = Event.create!(
      account: account,
      title: "Future Event",
      location: "Test Location",
      start_time: Time.current + 1.day,
      end_time: Time.current + 2.days
    )
    past_event = Event.create!(
      account: account,
      title: "Past Event",
      location: "Test Location",
      start_time: Time.current - 2.days,
      end_time: Time.current - 1.day
    )

    assert_includes Event.past, past_event
    assert_not_includes Event.past, future_event
  end

  test "by_account scope returns events for a specific account" do
    account1 = Account.create!(name: "Account 1")
    account2 = Account.create!(name: "Account 2")
    event1 = Event.create!(
      account: account1,
      title: "Event 1",
      location: "Location 1",
      start_time: Time.current + 1.day,
      end_time: Time.current + 2.days
    )
    event2 = Event.create!(
      account: account2,
      title: "Event 2",
      location: "Location 2",
      start_time: Time.current + 1.day,
      end_time: Time.current + 2.days
    )

    assert_includes Event.by_account(account1.id), event1
    assert_not_includes Event.by_account(account1.id), event2
  end

  test "association with account" do
    account = Account.create!(name: "Test Account")
    event = Event.create!(
      account: account,
      title: "Test Event",
      location: "Test Location",
      start_time: Time.current + 1.day,
      end_time: Time.current + 2.days
    )

    assert_equal account, event.account
  end

  test "association with attendees" do
    account = Account.create!(name: "Test Account")
    event = Event.create!(
      account: account,
      title: "Test Event",
      location: "Test Location",
      start_time: Time.current + 1.day,
      end_time: Time.current + 2.days
    )
    attendee1 = event.attendees.create!(name: "Attendee 1", email: "attendee1@example.com")
    attendee2 = event.attendees.create!(name: "Attendee 2", email: "attendee2@example.com")

    assert_includes event.attendees, attendee1
    assert_includes event.attendees, attendee2
  end

  test "destroying event destroys associated attendees" do
    account = Account.create!(name: "Test Account")
    event = Event.create!(
      account: account,
      title: "Test Event",
      location: "Test Location",
      start_time: Time.current + 1.day,
      end_time: Time.current + 2.days
    )
    event.attendees.create!(name: "Attendee", email: "attendee@example.com")

    assert_difference "Attendee.count", -1 do
      event.destroy
    end
  end

  test "upcoming and past scopes handle events at current time correctly" do
    freeze_time do
      account = Account.create!(name: "Test Account")
      current_event = Event.create!(
        account: account,
        title: "Current Event",
        location: "Test Location",
        start_time: Time.current,
        end_time: Time.current + 1.hour
      )

      assert_includes Event.upcoming, current_event
      assert_not_includes Event.past, current_event
    end
  end

  test "upcoming scope handles events in different time zones" do
    account = Account.create!(name: "Test Account")
    Time.use_zone("UTC") do
      Event.create!(
        account: account,
        title: "UTC Event",
        location: "UTC Location",
        start_time: Time.current + 1.day,
        end_time: Time.current + 2.days
      )
    end

    Time.use_zone("America/New_York") do
      Event.create!(
        account: account,
        title: "NY Event",
        location: "NY Location",
        start_time: Time.current + 1.day,
        end_time: Time.current + 2.days
      )
    end

    assert_equal 2, Event.upcoming.count
  end

  test "by_account scope returns multiple events for the same account" do
    account = Account.create!(name: "Test Account")
    event1 = Event.create!(
      account: account,
      title: "Event 1",
      location: "Location 1",
      start_time: Time.current + 1.day,
      end_time: Time.current + 2.days
    )
    event2 = Event.create!(
      account: account,
      title: "Event 2",
      location: "Location 2",
      start_time: Time.current + 3.days,
      end_time: Time.current + 4.days
    )

    events = Event.by_account(account.id)
    assert_equal 2, events.count
    assert_includes events, event1
    assert_includes events, event2
  end
end
