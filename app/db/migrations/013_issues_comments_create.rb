# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:issues_comments) do
      primary_key %i[issue_id comment_id]
      foreign_key :issue_id, :issues
      foreign_key :comment_id, :comments

      index %i[issue_id comment_id]
    end
  end
end
