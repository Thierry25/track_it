# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:projects) do
      uuid        :id, primary_key: true

      foreign_key :manager_id, table: :accounts
      foreign_key :department_id, table: :departments
      foreign_key :organization_id, table: :organizations

      String      :name_secure, null: false
      String      :description_secure, null: false
      DateTime    :deadline_secure, null: false
      String      :url

      DateTime    :created_at
      DateTime    :updated_at
    end
  end
end
