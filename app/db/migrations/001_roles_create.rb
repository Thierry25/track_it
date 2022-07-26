# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:roles) do
      primary_key :id

      String :role, null: false, unique: true
    end
  end
end
