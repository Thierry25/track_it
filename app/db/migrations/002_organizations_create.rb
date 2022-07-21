# frozen_string_literal : true

require 'sequel'

Sequel.migration do
  change do
    create_table(:organizations) do
      primary_key :id
      foreign_key :owner_id, table: :accounts

      String      :identifier, unique: true, null: false
      String      :name, null: false
      String      :logo
      String      :country, null: false

      DateTime    :created_at
      DateTime    :updated_at
    end

    alter_table(:accounts) do
      add_foreign_key :employer_id, :organizations
      add_unique_constraint %i[employer_id email]
    end
  end
end
