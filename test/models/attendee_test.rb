require "test_helper"

class AttendeeTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @account = Account.create!(name: "Test Account")
    @event = Event.create!(
      title: "Test Event",
      description: "Test Description",
      account: @account,
      start_time: 1.month.from_now,
      end_time: 1.month.from_now + 2.hours,
      location: "Online"
    )
  end

  test "attendee is valid when using valid attributes" do
    attendee = Attendee.new(name: "John Doe", email: "john@example.com", event: @event)
    assert attendee.valid?
  end

  test "attendee is invalid without a name" do
    attendee = Attendee.new(email: "john@example.com", event: @event)
    assert_not attendee.valid?
    assert_includes attendee.errors[:name], "can't be blank"
  end

  test "attendee is invalid without an email" do
    attendee = Attendee.new(name: "John Doe", event: @event)
    assert_not attendee.valid?
    assert_includes attendee.errors[:email], "can't be blank"
  end

  test "attendee is invalid without an associated event" do
    attendee = Attendee.new(name: "John Doe", email: "john@example.com")
    assert_not attendee.valid?
    assert_includes attendee.errors[:event], "must exist"
  end

  test "initial status is registered" do
    attendee = Attendee.create(name: "John Doe", email: "john@example.com", event: @event)

    assert_equal "registered", attendee.status
  end

  test "can transition from registered to attending" do
    attendee = Attendee.create(name: "John Doe", email: "john@example.com", event: @event)

    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      assert attendee.attend
    end
    assert_equal "attending", attendee.status
    assert_enqueued_with(
      job: ActionMailer::MailDeliveryJob,
      args: [ "AttendeeMailer", "attending", "deliver_now", { params: { attendee: attendee }, args: [] } ]
    )
  end

  test "can transition from attending to confirmed" do
    attendee = Attendee.create(name: "John Doe", email: "john@example.com", event: @event)

    attendee.attend

    assert_no_enqueued_emails do
      attendee.confirm_attendance
    end
    assert_equal "confirmed", attendee.status
  end

  test "can transition from registered to cancelled" do
    attendee = Attendee.create(name: "John Doe", email: "john@example.com", event: @event)

    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      assert attendee.cancel
    end

    assert_equal "cancelled", attendee.status
    assert_enqueued_with(
      job: ActionMailer::MailDeliveryJob,
      args: [ "AttendeeMailer", "cancelled", "deliver_now", { params: { attendee: attendee }, args: [] } ]
    )
  end

  test "can transition from registered to checkedin" do
    attendee = Attendee.create(name: "John Doe", email: "john@example.com", event: @event)


    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      assert attendee.checkin
    end

    assert_equal "checkedin", attendee.status
    assert_enqueued_with(
      job: ActionMailer::MailDeliveryJob,
      args: [ "AttendeeMailer", "checkedin", "deliver_now", { params: { attendee: attendee }, args: [] } ]
    )
  end

  test "can transition from attending to cancelled" do
    attendee = Attendee.create(name: "John Doe", email: "john@example.com", event: @event)

    attendee.attend
    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      assert attendee.cancel
    end

    assert_equal "cancelled", attendee.status
    assert_enqueued_with(
      job: ActionMailer::MailDeliveryJob,
      args: [ "AttendeeMailer", "cancelled", "deliver_now", { params: { attendee: attendee }, args: [] } ]
    )
  end

  test "can transition from attending to checkedin" do
    attendee = Attendee.create(name: "John Doe", email: "john@example.com", event: @event)

    attendee.attend

    assert attendee.checkin
    assert_equal "checkedin", attendee.status
    assert_enqueued_with(
      job: ActionMailer::MailDeliveryJob,
      args: [ "AttendeeMailer", "checkedin", "deliver_now", { params: { attendee: attendee }, args: [] } ]
    )
  end

  test "cannot transition from cancelled to attending" do
    attendee = Attendee.create(name: "John Doe", email: "john@example.com", event: @event)

    attendee.cancel
    assert_not attendee.attend
  end

  test "cannot transition from checkedin to attending" do
    attendee = Attendee.create(name: "John Doe", email: "john@example.com", event: @event)

    attendee.checkin
    assert_not attendee.attend
  end
end
