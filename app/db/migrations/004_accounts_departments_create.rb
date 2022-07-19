# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(employee_id: :accounts, department_id: :departments)
  end
end
