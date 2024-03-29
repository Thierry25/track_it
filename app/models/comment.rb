# frozen_string_literal: true

require 'json'
require 'sequel'

module TrackIt
  # Models a comment
  class Comment < Sequel::Model
    many_to_one         :submitter, class: :'TrackIt::Account'

    # NAME SUCKS
    many_to_many        :related_projects,
                        class: :'TrackIt::Project',
                        join_table: :projects_comments,
                        left_key: :comment_id, right_key: :project_id

    many_to_many        :related_issues,
                        class: :'TrackIt::Issue',
                        join_table: :issues_comments,
                        left_key: :comment_id, right_key: :issue_id

    plugin              :uuid, field: :id
    plugin              :timestamps, update_on_create: true
    plugin              :whitelist_security
    plugin              :association_dependencies,
                        related_projects: :nullify,
                        related_issues: :nullify

    set_allowed_columns :content

    def to_h
      {
        type: 'comment',
        attributes: {
          id:,
          content:
        }
      }
    end

    def full_details
      to_h.merge(
        relationships: {
          submitter:,
          related_projects:,
          related_issues:
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
