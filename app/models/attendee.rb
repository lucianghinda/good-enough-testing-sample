# frozen_string_literal: true

class Attendee < ApplicationRecord
  belongs_to :event, inverse_of: :attendees

  validates :name, presence: true
  validates :email, presence: true

  state_machine :status, initial: :registered do
    event :attend do
      transition registered: :attending
    end
    after_transition on: :attend, do: :send_attending_email

    event :confirm_attendance do
      transition %i[attending checkedin] => :confirmed
    end

    event :cancel do
      transition %i[registered attending] => :cancelled
    end
    after_transition on: :cancel, do: :send_cancelled_email

    event :checkin do
      transition %i[registered attending] => :checkedin
    end
    after_transition on: :checkin, do: :send_checkedin_email
  end

  private

  def send_attending_email
    AttendeeMailer.with(attendee: self).attending.deliver_later
  end

  def send_cancelled_email
    AttendeeMailer.with(attendee: self).cancelled.deliver_later
  end

  def send_checkedin_email
    AttendeeMailer.with(attendee: self).checkedin.deliver_later
  end
end
