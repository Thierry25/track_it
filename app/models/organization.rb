# frozen_string_literal : true

require 'sequel'
require 'json'

module TrackIt
  # Models an organization
  class Organization < Sequel::Model
    one_to_many         :departments
    one_to_many         :employees, class: :'TrackIt::Account', key: :employer_id

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
                        projects: :nullify,
                        employees: :nullify

    plugin              :whitelist_security
    plugin              :association_dependencies,
                        departments: :destroy,
                        employees: :destroy,
                        projects: :nullify
    # employees: :nullify

    def projects
      departments.map do |department|
        department.projects.all
      end
    end

    set_allowed_columns :name, :logo, :country, :identifier

    plugin              :timestamps, update_on_create: true

    def to_json(options = {})
      JSON(
        {
          type: 'organization',
          id:,
          name:,
          logo:,
          country:,
          identifier:
        }, options
      )
    end
  end
end
