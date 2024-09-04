# frozen_string_literal: true

class Account < ApplicationRecord
  enum :account_type, %w[ free standard premium vip ].index_by(&:itself), prefix: true
  SOON_TO_EXPIRE_IN_DAYS = 30.days

  has_many :bookings, dependent: :destroy, inverse_of: :account
  has_many :events, dependent: :destroy, inverse_of: :account

  validates :name, presence: true

  scope :active, -> { where(archived_at: nil).where(closed_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }
  scope :closed, -> { where.not(closed_at: nil) }

  def status
    case
    when archived? then Accounts::Statuses::Archived
    when closed? then Accounts::Statuses::Closed
    when expiring_soon? then Accounts::Statuses::Expiring
    when update_required? then Accounts::Statuses::UpdateRequired
    else Accounts::Statuses::Active
    end
  end

  def archive!
    return if archived?
    self.archived_at = Time.current
    save!
  end

  def archived?
    archived_at.present?
  end

  def close!
    return if closed?
    self.closed_at = Time.current
    save!
  end

  def closed?
    closed_at.present?
  end

  def eternal?
    expires_at.nil?
  end

  def expired?
    return false if eternal?

    expires_at < Date.current
  end

  def expiring_soon?
    return false if eternal?
    return false if expired?

    expires_at.in?(..SOON_TO_EXPIRE_IN_DAYS.from_now.to_date)
  end

  def update_required?
    website.blank? || expired?
  end
end
