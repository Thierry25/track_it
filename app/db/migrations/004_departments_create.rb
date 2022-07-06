# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:departments) do
      primary_key :id
      foreign_key :organization_id, table: :organizations

      String      :name
      # Other fields to come after

      DateTime    :created_at
      DateTime    :updated_at
    end
  end
end
