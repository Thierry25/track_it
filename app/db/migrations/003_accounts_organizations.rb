# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:accounts_organizations) do
      primary_key %i[employee_id employer_id]
      foreign_key :employee_id, :accounts
      foreign_key :employer_id, :organizations

      String :role, null: false
      index %i[employee_id employer_id]
    end
  end
end
