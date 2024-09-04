# Preview all emails at http://localhost:3000/rails/mailers/attendee_mailer
class AttendeeMailerPreview < ActionMailer::Preview
  def registered
    account = Account.new(name: "Test Account")
    event = Event.new(title: "Test Event", description: "Test Description", account: account)
    attendee = Attendee.new(name: "John Doe", email: "john@example.com", event: event)
    AttendeeMailer.with(attendee: attendee).registered
  end

  def attending
    account = Account.new(name: "Test Account")
    event = Event.new(title: "Test Event", description: "Test Description", account: account)
    attendee = Attendee.new(name: "John Doe", email: "john@example.com", event: event)
    AttendeeMailer.with(attendee: attendee).attending
  end

  def noshow
    account = Account.new(name: "Test Account")
    event = Event.new(title: "Test Event", description: "Test Description", account: account)
    attendee = Attendee.new(name: "John Doe", email: "john@example.com", event: event)
    AttendeeMailer.with(attendee: attendee).noshow
  end

  def cancelled
    account = Account.new(name: "Test Account")
    event = Event.new(title: "Test Event", description: "Test Description", account: account)
    attendee = Attendee.new(name: "John Doe", email: "john@example.com", event: event)
    AttendeeMailer.with(attendee: attendee).cancelled
  end
end
