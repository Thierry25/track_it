# frozen_string_literal: true

require 'json'
require 'base64'

module TrackIt
  # Models a secret issue
  class Issue < Sequel::Model
    many_to_one :project

    plugin :uuid, field: :id
    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :type, :priority, :status, :description, :title

    # Secure getters and setters
    def description
      SecureDB.decrypt(description_secure)
    end

    def description=(plaintext)
      self.description_secure = SecureDB.encrypt(plaintext)
    end

    def title
      SecureDB.decrypt(title_secure)
    end

    def title=(plaintext)
      self.title_secure = SecureDB.encrypt(plaintext)
    end

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
