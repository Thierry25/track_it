# frozen_string_literal : true

require 'sequel'

Sequel.migration do
  change do
    create_table(:organizations) do
      primary_key :id
      foreign_key :owner_id, table: :accounts

      String      :name, unique: true, null: false
      String      :logo
      String      :country, null: false

      DateTime    :created_at
      DateTime    :updated_at
    end
  end
end
