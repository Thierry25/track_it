# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:accounts) do
      primary_key :id
      # foreign_key :department_id, table: :departments

      # String :username, null: false, unique: true
      String      :email, null: false, unique: true
      String      :password_digest
      String      :role, null: false
      String      :picture

      DateTime    :created_at
      DateTime    :updated_at

      # To test if working correctly
      unique %i[department_id email role]
    end
  end
end
