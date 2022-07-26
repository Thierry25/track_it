# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:accounts_departments) do
      primary_key %i[department_id employee_id]
      foreign_key :department_id, :departments
      foreign_key :employee_id, :accounts

      foreign_key :role_id, :roles
      index %i[employee_id department_id]
    end
  end
end
