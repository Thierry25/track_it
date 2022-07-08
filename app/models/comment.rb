# frozen_string_literal: true

require 'json'
require 'sequel'

module TrackIt
  # Models a comment
  class Comment < Sequel::Model
    many_to_one :issue
    many_to_one :commenter, class: :'TrackIt::Account'

    plugin              :timestamps, update_on_create: true
    plugin              :whitelist_security

    set_allowed_columns :content

    def to_json(options = {})
      JSON(
        {
          type: 'comment',
          id:,
          content:
        }, options
      )
    end
  end
end
