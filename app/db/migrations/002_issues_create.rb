# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:issues) do
      primary_key :id
      foreign_key :project_id, table: :projects

      String :type, null: false
      String :priority, null: false
      String :status, null: false, default: 'Waiting'
      String :description, null: false
      String :title, null: false

      DateTime :created_at
      DateTime :updated_at

      unique %i[project_id description title]
    end
  end
end
