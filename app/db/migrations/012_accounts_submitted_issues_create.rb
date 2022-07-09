# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:accounts_submitted_issues) do
      primary_key %i[submitter_id issue_id]
      foreign_key :submitter_id, :accounts
      foreign_key :issue_id, :issues

      index %i[submitter_id issue_id]
    end
  end
end
