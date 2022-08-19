# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:issues) do
      # primary_key :id
      uuid :id, primary_key: true
      # foreign_key :project_id, table: :projects
      foreign_key :submitter_id, table: :accounts
      # foreign_key :assignee_id, table: :accounts
      String      :ticket_number, null: false, unique: true
      String      :type, null: false
      String      :priority, null: false
      String      :status, null: false, default: 'Waiting'
      String      :description_secure, null: false
      String      :title_secure, null: false
      String      :completed, null: false

      DateTime    :created_at
      DateTime    :updated_at

      # To think that through
      unique %i[description_secure title_secure]
    end
  end
end
