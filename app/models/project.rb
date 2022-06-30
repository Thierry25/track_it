# frozen_string_literal: true

require 'json'
require 'sequel'

module TrackIt
  # Models a project
  class Project < Sequel::Model
    one_to_many :issues
    plugin :association_dependencies, issues: :destroy

    plugin :timestamps

    # rubocop:disable Metrics/MethodLength
    def to_json(_options = {})
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
