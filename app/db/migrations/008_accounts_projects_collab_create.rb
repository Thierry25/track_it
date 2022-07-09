# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:accounts_projects_collab) do
      primary_key %i[collaborator_id project_id]
      foreign_key :collaborator_id, :accounts
      foreign_key :project_id, :projects

      index %i[collaborator_id project_id]
    end
  end
end
