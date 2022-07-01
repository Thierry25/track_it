# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:issues) do
      uuid :id, primary_key: true
      foreign_key :project_id, table: :projects

      String :type, null: false
      String :priority, null: false
      String :status, null: false, default: 'Waiting'
      String :description_secure, null: false
      String :title_secure, null: false

      DateTime :created_at
      DateTime :updated_at

      unique %i[project_id description_secure title_secure]
    end
  end
end
