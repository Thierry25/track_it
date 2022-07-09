# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(submitter_id: :accounts, issue_id: :issues)
  end
end
