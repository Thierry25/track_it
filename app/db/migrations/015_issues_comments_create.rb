# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(issue_id: :issues, comment_id: :comments)
  end
end
