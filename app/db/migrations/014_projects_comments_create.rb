# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(project_id: :projects, comment_id: :comments)
  end
end
