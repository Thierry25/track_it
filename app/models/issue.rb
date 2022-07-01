# frozen_string_literal: true

require 'json'
require 'base64'

module TrackIt
  # Models a secret issue
  class Issue < Sequel::Model
    many_to_one :project

    plugin :timestamps

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type_: 'issue',
            attributes: {
              id:,
              type:,
              priority:,
              status:,
              description:,
              title:
            }
          },
          included: {
            project:
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
