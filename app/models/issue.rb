# frozen_string_literal: true

require 'json'
require 'base64'

module TrackIt
  # Models a secret issue
  class Issue < Sequel::Model
    # many_to_one         :project
    many_to_one         :submitter

    many_to_many        :assignees,
                        class: :'TrackIt::Account',
                        join_table: :accounts_issues,
                        left_key: :issue_id, right_key: :assignee_id

    many_to_many        :comments,
                        class: :'TrackIt::Comment',
                        join_table: :issues_comments,
                        left_key: :issue_id, right_key: :comment_id

    many_to_many        :related_projects,
                        class: :'TrackIt::Project',
                        join_table: :projects_issues,
                        left_key: :issue_id, right_key: :project_id

    plugin              :uuid, field: :id
    plugin              :timestamps
    plugin              :whitelist_security
    plugin              :association_dependencies,
                        comments: :nullify,
                        assignees: :nullify,
                        related_issues: :nullify
    # submitters: :nullify

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
            type: 'issue',
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
