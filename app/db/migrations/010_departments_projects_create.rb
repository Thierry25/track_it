# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(department_id: :departments, project_id: :projects)
  end
end
