# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:comments) do
      primary_key :id
      foreign_key :commenter_id, table: :accounts

      String      :content, null: false, default: ''

      DateTime    :created_at
      DateTime    :updated_at
    end
  end
end