# frozen_string_literal: true

require 'json'
require 'sequel'

module TrackIt
  # Models a project
  class Project < Sequel::Model
    many_to_one         :manager, class: :'TrackIt::Account'
    many_to_one         :organization, class: :'TrackIt::Organization'
    many_to_one         :department, class: :'TrackIt::Department'

    one_to_many         :issues
    one_to_many         :comments, class: :'TrackIt::ProjectComment', key: :commenter_id

    plugin              :uuid, field: :id
    plugin              :timestamps
    plugin              :whitelist_security

    plugin              :association_dependencies,
                        issues: :destroy,
                        comments: :destroy

    set_allowed_columns :name, :description, :deadline, :url

    # Secure getters and setters
    def name
      SecureDB.decrypt(name_secure)
    end

    def name=(plaintext)
      self.name_secure = SecureDB.encrypt(plaintext)
    end

    def description
      SecureDB.decrypt(description_secure)
    end

    def description=(plaintext)
      self.description_secure = SecureDB.encrypt(plaintext)
    end

    def deadline
      SecureDb.decrypt(deadline_secure)
    end

    def deadline=(plaintext)
      self.deadline_secure = SecureDB.encrypt(plaintext)
    end

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'project',
            attributes: {
              id:,
              name:,
              description:,
              deadline:,
              url:
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
