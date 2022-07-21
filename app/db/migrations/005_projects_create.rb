# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:projects) do
      uuid        :id, primary_key: true

      foreign_key :department_id, table: :departments

      String      :name, null: false
      String      :description_secure, null: false
      # DateTime    :deadline_secure, null: false
      String      :url_secure

      DateTime    :created_at
      DateTime    :updated_at

      unique %i[department_id name]
    end
  end
end
