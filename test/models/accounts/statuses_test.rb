require "test_helper"

module Accounts
  class AgeValidatorBoundaryValueTest < ActiveSupport::TestCase
    test "serializes the value" do
      assert_equal :active, Accounts::Statuses::Active.serialize
      assert_equal :archived, Accounts::Statuses::Archived.serialize
      assert_equal :closed, Accounts::Statuses::Closed.serialize
      assert_equal :expired, Accounts::Statuses::Expired.serialize
      assert_equal :expiring, Accounts::Statuses::Expiring.serialize
      assert_equal :update_required, Accounts::Statuses::UpdateRequired.serialize
    end
  end
end
