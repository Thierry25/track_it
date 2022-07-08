# frozen_string_literal : true

require 'sequel'
require 'json'

module TrackIt
  # Models an organization
  class Organization < Sequel::Model
    # one_to_many :departments, class: :'TrackIt::Department', key: :organization_id
    # one_to_many :projects, class: :'TrackIt::Project', key: :organization_id

    one_to_many         :departments
    one_to_many         :projects

    many_to_one         :owner, class: :'TrackIt::Account'

    plugin              :association_dependencies,
                        departments: :destroy,
                        projects: :destroy

    plugin              :whitelist_security
    plugin              :association_dependencies,
                        projects: :destroy,
                        departments: :destroy

    set_allowed_columns :name, :logo, :country

    plugin              :timestamps, update_on_create: true

    def to_json(options = {})
      JSON(
        {
          type: 'organization',
          id:,
          name:,
          logo:,
          country:
        }, options
      )
    end
  end
end
