require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test "fixtures are working correctly for #expired" do
    assert_not accounts(:expirable_account).expired?
    assert accounts(:expired_account).expired?
    assert_not accounts(:expiring_today_account).expired?
    assert_not accounts(:eternal_account).expired?
  end

  test "fixtures are working correctly for #eternal" do
    assert_not accounts(:expirable_account).eternal?
    assert accounts(:eternal_account).eternal?
  end

  test "valid account without optional attributes can be saved" do
    account = Account.new(name: "John Doe", expires_at: nil, website: nil)

    assert account.save
    assert account.persisted?
  end

  test "valid account with optional attributes can be saved" do
    account = Account.new(name: "John Doe", expires_at: 2.months.from_now.to_date, website: "https://www.example.com")

    assert account.save
    assert account.persisted?
  end

  test "eternal accounts are not expired" do
    expires_at = nil

    assert_not Account.new(expires_at: expires_at).expired?
  end

  test "account one day before expiration is expired" do
    expires_at = 1.day.ago.to_date

    assert Account.new(expires_at: expires_at).expired?
  end

  test "account one day after expiration is not expired" do
    expires_at = 1.day.from_now.to_date

    assert_not Account.new(expires_at: expires_at).expired?
  end

  test "account in the same day as expiration is not expired" do
    expires_at = Time.current.to_date

    assert_not Account.new(expires_at: expires_at).expired?
  end

  test "account in the future is not expired" do
    expires_at = (Time.current + 1.day).to_date

    assert_not Account.new(expires_at: expires_at).expired?
  end

  test "account with nil expiration is eternal" do
    expires_at = nil

    assert Account.new(expires_at: expires_at).eternal?
  end

  test "account with blank website attribute is update required" do
    website = ""

    assert Account.new(website: website).update_required?
  end

  test "account with non-blank website attribute is not update required" do
    website = "https://www.example.com"

    assert_not Account.new(website: website).update_required?
  end

  test "active scope returns only non-archived and non-closed accounts" do
    active_account = Account.create!(name: "Active Account")
    archived_account = Account.create!(name: "Archived Account", archived_at: Time.current)
    closed_account = Account.create!(name: "Closed Account", closed_at: Time.current)

    assert_includes Account.active, active_account
    assert_not_includes Account.active, archived_account
    assert_not_includes Account.active, closed_account
  end

  test "archived scope returns only archived accounts" do
    active_account = Account.create!(name: "Active Account")
    archived_account = Account.create!(name: "Archived Account", archived_at: Time.current)

    assert_includes Account.archived, archived_account
    assert_not_includes Account.archived, active_account
  end

  test "closed scope returns only closed accounts" do
    active_account = Account.create!(name: "Active Account")
    closed_account = Account.create!(name: "Closed Account", closed_at: Time.current)

    assert_includes Account.closed, closed_account
    assert_not_includes Account.closed, active_account
  end

  test "archive! method archives an active account" do
    account = Account.create!(name: "Test Account")
    assert_nil account.archived_at

    account.archive!

    assert_not_nil account.archived_at
    assert account.archived?
  end

  test "archive! method does nothing for an already archived account" do
    freeze_time do
      archived_at = 1.day.ago
      account = Account.create!(name: "Archived Account", archived_at: archived_at)

      account.archive!
      assert_equal archived_at.iso8601(1), account.archived_at.iso8601(1)
    end
  end

  test "archive! method does not change updated_at for an already archived account" do
    account = Account.create!(name: "Archived Account", archived_at: 1.day.ago)
    original_updated_at = account.updated_at

    travel 1.hour do
      account.archive!
    end

    assert_equal original_updated_at.iso8601(1), account.reload.updated_at.iso8601(1)
  end

  test "archived? returns true for archived accounts" do
    account = Account.create!(name: "Archived Account", archived_at: Time.current)

    assert account.archived?
  end

  test "archived? returns false for active accounts" do
    account = Account.create!(name: "Active Account")

    assert_not account.archived?
  end

  # New tests for closed functionality
  test "close! method closes an active account" do
    account = Account.create!(name: "Test Account")
    assert_nil account.closed_at

    account.close!

    assert_not_nil account.closed_at
    assert account.closed?
  end

  test "close! method does nothing for an already closed account" do
    freeze_time do
      closed_at = 1.day.ago
      account = Account.create!(name: "Closed Account", closed_at: closed_at)

      account.close!
      assert_equal closed_at.iso8601(1), account.closed_at.iso8601(1)
    end
  end

  test "close! method does not change updated_at for an already closed account" do
    account = Account.create!(name: "Closed Account", closed_at: 1.day.ago)
    original_updated_at = account.updated_at

    travel 1.hour do
      account.close!
    end

    assert_equal original_updated_at.iso8601(1), account.reload.updated_at.iso8601(1)
  end

  test "closed? returns true for closed accounts" do
    account = Account.create!(name: "Closed Account", closed_at: Time.current)

    assert account.closed?
  end

  test "closed? returns false for active accounts" do
    account = Account.create!(name: "Active Account")

    assert_not account.closed?
  end


  test "status returns archived for archived accounts" do
    account = Account.create!(name: "Archived Account", archived_at: Time.current)
    assert_equal Accounts::Statuses::Archived, account.status
  end

  test "status returns closed for closed accounts" do
    account = Account.create!(name: "Closed Account", closed_at: Time.current)
    assert_equal Accounts::Statuses::Closed, account.status
  end

  test "status returns expiring for expiring accounts" do
    account = Account.create!(name: "Expiring Account", expires_at: 5.day.from_now)
    assert_equal Accounts::Statuses::Expiring, account.status
  end

  test "status returns update required for accounts with website blank" do
    account = Account.create!(name: "Update Required Account", website: "", expires_at: nil)
    assert_equal Accounts::Statuses::UpdateRequired, account.status
  end

  test "status returns update required for expired accounts" do
    account = Account.create!(
      name: "Update Required Account",
      website: "https://www.example.com",
      expires_at: 3.days.ago
    )
    assert_equal Accounts::Statuses::UpdateRequired, account.status
  end
end
