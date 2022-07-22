# frozen_string_literal: true

require 'sequel'
require 'json'

module TrackIt
  # Models a department within a organization
  class Department < Sequel::Model
    one_to_many         :projects

    many_to_one         :organization

    many_to_many        :employees,
                        class: :'TrackIt::Account',
                        join_table: :accounts_departments,
                        left_key: :department_id, right_key: :employee_id

    plugin              :timestamps, update_on_create: true
    plugin              :whitelist_security
    plugin              :association_dependencies,
                        projects: :destroy,
                        employees: :nullify

    set_allowed_columns :name

    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'department',
            attributes: {
              id:,
              name:
            }
          }
        }, options
      )
    end
  end
end
