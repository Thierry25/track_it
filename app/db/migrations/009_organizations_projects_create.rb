# frozen_string_litereal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(organization_id: :organizations, project_id: :projects)
  end
end
