# frozen_string_literal: true

module Accounts
  module Statuses
    Status = Data.define(:value) do
      def serialize = value
    end

    Active = Status.new(:active).freeze
    Archived = Status.new(:archived).freeze
    Closed = Status.new(:closed).freeze
    Expired = Status.new(:expired).freeze
    Expiring = Status.new(:expiring).freeze
    UpdateRequired = Status.new(:update_required).freeze
  end
end
