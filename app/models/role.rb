# frozen_string_literal: true

require 'sequel'
require 'json'

module TrackIt
  # Models a role for an account
  class Role < Sequel::Model
    def to_json(options = {})
      JSON(
        {
          type: 'role',
          id:,
          role:
        }, options
      )
    end
  end
end
