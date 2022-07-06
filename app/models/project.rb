# frozen_string_literal: true

require 'json'
require 'sequel'

module TrackIt
  # Models a project
  class Project < Sequel::Model
    many_to_one :manager, class: :'TrackIt::Account'
    many_to_one :organization, class: :'TrackIt::Organization'
    many_to_one :department, class: :'TrackIt::Department'

    one_to_many :issues

    plugin :uuid, field: :id
    plugin :timestamps
    plugin :whitelist_security

    plugin :association_dependencies, issues: :destroy

    set_allowed_columns :name, :description, :type, :organization

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type_: 'project',
            attributes: {
              id:,
              name:,
              description:,
              type:,
              organization:
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
