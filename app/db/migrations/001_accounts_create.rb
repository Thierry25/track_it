# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:accounts) do
      primary_key :id
      # foreign_key :organization_id, table: :organizations

      # String :username, null: false, unique: true
      String      :first_name, null: false
      String      :last_name, null: false
      String      :username, null: false, unique: true
      String      :email, null: false
      String      :password_digest
      # String      :role, null: false, default: 'super'
      String      :picture

      DateTime    :created_at
      DateTime    :updated_at

      # To test if working correctly
      # unique %i[organization_id email]
    end
  end
end
