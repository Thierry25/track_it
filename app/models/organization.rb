# frozen_string_literal : true

require 'sequel'
require 'json'

module TrackIt
  # Models an organization
  class Organization < Sequel::Model
    one_to_many         :departments
    # one_to_many         :employees, class: :'TrackIt::Account', key: :employer_id

    many_to_one         :owner, class: :'TrackIt::Account'

    many_to_many        :projects,
                        class: :'TrackIt::Project',
                        join_table: :organizations_projects,
                        left_key: :organization_id, right_key: :project_id

    # many_to_many        :employees,
    #                     class: :'TrackIt::Account',
    #                     join_table: :accounts_organizations,
    #                     left_key: :employer_id, right_key: :employee_id

    plugin              :association_dependencies,
                        departments: :destroy,
                        projects: :nullify
    # employees: :nullify

    plugin              :whitelist_security
    plugin              :association_dependencies,
                        departments: :destroy,
                        projects: :nullify
    # employees: :nullify

    def projects
      projs = []
      departments.each do |department|
        department.projects.each do |proj|
          projs.append(proj)
        end
      end
      projs
    end

    def employees
      emps = []
      departments.each do |department|
        department.employees.each do |emp|
          emps.append(emp)
        end
      end
      emps
    end

    set_allowed_columns :name, :logo, :country, :identifier

    plugin              :timestamps, update_on_create: true

    def to_h
      {
        type: 'organization',
        attributes: {
          id:,
          name:,
          logo:,
          country:,
          identifier:
        }
      }
    end

    def full_details
      to_h.merge(
        relationships: {
          owner:,
          departments:,
          projects:
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
