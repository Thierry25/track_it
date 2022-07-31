# frozen_string_literal: true

app = TrackIt::Api
require 'sequel'

Sequel.migration do
  change do
    create_table(:accounts) do
      app.DB.transaction do
        dataset = app.DB[:roles]
        dataset.insert(role: 'admin')
        dataset.insert(role: 'project manager')
        dataset.insert(role: 'developer')
        dataset.insert(role: 'tester')
      end

      primary_key :id

      String      :first_name, null: false
      String      :last_name, null: false
      String      :username, null: false, unique: true
      String      :email, null: false, unique: true
      String      :password_digest
      String      :picture

      DateTime    :created_at
      DateTime    :updated_at
    end
  end
end
