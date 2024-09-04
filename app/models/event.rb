# frozen_string_literal: true

class Event < ApplicationRecord
  belongs_to :account, inverse_of: :events
  has_many :attendees, dependent: :destroy, inverse_of: :event

  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :title, presence: true
  validates :location, presence: true
  validate  :end_time_after_start_time

  enum :status, %w[ pending confirmed cancelled ].index_by(&:itself), prefix: true

  scope :upcoming, -> { where("start_time >= ?", Time.current) }
  scope :past, -> { where("end_time < ?", Time.current) }
  scope :by_account, ->(account_id) { where(account_id: account_id) }

  private

  def end_time_after_start_time
    return if end_time.blank? || start_time.blank?

    if end_time <= start_time
      errors.add(:end_time, "must be after the start time")
    end
  end
end
