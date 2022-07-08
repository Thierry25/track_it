# frozen_string_literal: true

module TrackIt
  # Models a comment related to a project
  class ProjectComment < Sequel::Model
    many_to_one         :project
    many_to_one         :commenter, class: :'TrackIt::Account'

    plugin              :timestamps, update_on_create: true
    plugin              :whitelist_security

    set_allowed_columns :content

    def to_json(options = {})
      JSON(
        {
          type: 'project_comment',
          id:,
          content:
        }, options
      )
    end
  end
end
