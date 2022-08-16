# frozen_string_literal: true

require 'json'
require 'sequel'

module TrackIt
  # Models a project
  class Project < Sequel::Model
    many_to_one         :department, class: :'TrackIt::Department'
    # one_to_many         :issues, class: :'TrackIt::Issue'

    many_to_many        :collaborators,
                        class: :'TrackIt::Account',
                        join_table: :accounts_projects_collab,
                        left_key: :project_id, right_key: :collaborator_id

    many_to_many        :managers,
                        class: :'TrackIt::Account',
                        join_table: :accounts_projects,
                        left_key: :project_id, right_key: :manager_id

    many_to_many        :comments,
                        class: :'TrackIt::Comment',
                        join_table: :projects_comments,
                        left_key: :project_id, right_key: :comment_id

    many_to_many        :issues,
                        class: :'TrackIt::Issue',
                        join_table: :projects_issues,
                        left_key: :project_id, right_key: :issue_id

    # THIS NAME SUCKS, FIND A BETTER NAME
    many_to_many        :parent_organizations,
                        class: :'TrackIt::Organization',
                        join_table: :organizations_projects,
                        left_key: :project_id, right_key: :organization_id

    # plugin              :uuid, field: :id
    plugin              :timestamps
    plugin              :whitelist_security

    plugin              :association_dependencies,
                        collaborators: :nullify,
                        managers: :nullify,
                        comments: :nullify,
                        parent_organizations: :nullify,
                        issues: :nullify

    set_allowed_columns :name, :description, :url
    # :deadline

    # Secure getters and setters
    def description
      SecureDB.decrypt(description_secure)
    end

    def description=(plaintext)
      self.description_secure = SecureDB.encrypt(plaintext)
    end

    def url
      SecureDB.decrypt(url_secure)
    end

    def url=(plaintext)
      self.url_secure = SecureDB.encrypt(plaintext)
    end

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      #  include: {
      #       project:
      #     }
      JSON(
        {
          data: {
            type: 'project',
            attributes: {
              id:,
              name:,
              description:,
              url:
              # deadline:,
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
