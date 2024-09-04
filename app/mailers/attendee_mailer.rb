class AttendeeMailer < ApplicationMailer
  def registered
    @attendee = params[:attendee]
    mail(to: @attendee.email, subject: "You're registered for #{@attendee.event.title}")
  end

  def attending
    @attendee = params[:attendee]
    mail(to: @attendee.email, subject: "You're attending #{@attendee.event.title}")
  end

  def checkedin
    @attendee = params[:attendee]
    mail(to: @attendee.email, subject: "Here is your starter pack for #{@attendee.event.title}")
  end

  def cancelled
    @attendee = params[:attendee]
    mail(to: @attendee.email, subject: "Your registration for #{@attendee.event.title} has been cancelled")
  end
end
