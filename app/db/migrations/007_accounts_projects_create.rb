# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:accounts_projects) do
      primary_key %i[manager_id project_id]
      foreign_key :manager_id, :accounts
      foreign_key :project_id, :projects

      index %i[manager_id project_id]
    end
  end
end
