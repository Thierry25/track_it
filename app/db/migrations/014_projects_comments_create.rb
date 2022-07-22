# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:projects_comments) do
      primary_key %i[project_id comment_id]
      foreign_key :project_id, :projects
      foreign_key :comment_id, :comments

      index %i[project_id comment_id]
    end
  end
end
