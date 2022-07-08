# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

module TrackIt
  # Models a registered account
  class Account < Sequel::Model
    one_to_many         :managed_projects, class: :'TrackIt::Project', key: :manager_id
    one_to_many         :owned_organizations, class: :'TrackIt::Organization', key: :owner_id
    one_to_many         :submitted_issues, class: :'TrackIt::Issue', key: :submitter_id
    one_to_many         :submitted_comments, class: :'TrackIt::Comment', key: :commenter_id
    one_to_many         :submitted_projects_comments, class: :'TrackIt::ProjectComment', key: :commenter_id

    many_to_one         :team, class: :'TrackIt::Department'

    many_to_many        :positions,
                        class: :'TrackIt::Organization',
                        join_table: :accounts_organizations,
                        left_key: :employee_id, right_key: :employer_id

    many_to_many        :assigned_issues,
                        class: :'TrackIt::Issue',
                        join_table: :accounts_issues,
                        left_key: :assignee_id, right_key: :issue_id

    plugin              :association_dependencies,
                        managed_projects: :destroy,
                        submitted_issues: :destroy,
                        submitted_comments: :destroy,
                        submitted_projects_comments: :destroy,
                        positions: :nullify,
                        assigned_issues: :nullify

    plugin              :whitelist_security
    set_allowed_columns :email, :password, :role, :picture

    plugin              :timestamps, update_on_create: true

    # def managed_projects
    #   managed_projects
    # end

    # def owned_organizations
    #   owned_organizations
    # end

    # def my_issues
    #   assigned_issues
    # end

    # def submitted_issues
    #   submitted_issues
    # end

    # def submitted_comments
    #   submitted_comments
    # end

    # def positions
    #   positions
    # end

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = TrackIt::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end

    def to_json(options = {})
      JSON(
        {
          type: 'account',
          id:,
          username:,
          email:,
          role:,
          picture:
        }, options
      )
    end
  end
end
