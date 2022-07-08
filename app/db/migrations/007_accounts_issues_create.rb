# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:accounts_issues) do
      primary_key %i[assignee_id issue_id]
      foreign_key :assignee_id, :accounts
      foreign_key :issue_id, :issues

      index %i[assignee_id issue_id]
      unique %i[assignee_id issue_id]
    end
  end
end
