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
                        left_key: :department_id, right_key: :employee_id,
                        select: [Sequel[:accounts].*, Sequel[:accounts_departments][:role_id]]

    plugin              :timestamps, update_on_create: true
    plugin              :whitelist_security
    plugin              :association_dependencies,
                        projects: :destroy,
                        employees: :nullify

    set_allowed_columns :name

    def admins
      employees&.select do |emp|
        emp.values[:role_id] == 1
      end
    end

    def project_managers
      employees&.select do |emp|
        emp.values[:role_id] == 2
      end
    end

    def soft_devs
      employees&.select do |emp|
        emp.values[:role_id] == 3
      end
    end

    def testers
      employees&.select do |emp|
        emp.values[:role_id] == 4
      end
    end

    def to_h
      {
        type: 'department',
        attributes: {
          id:,
          name:
        }
      }
    end

    def full_details
      to_h.merge(
        relationships: {
          organization:,
          projects:,
          employees:,
          admins:,
          project_managers:,
          soft_devs:,
          testers:
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
