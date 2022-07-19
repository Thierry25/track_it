# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

module TrackIt
  # Models a registered account
  class Account < Sequel::Model
    one_to_many         :submitted_comments, class: :'TrackIt::Comment', key: :commenter_id
    one_to_many         :submitted_issues, class: :'TrackIt::Issue', key: :submitter_id
    one_to_many         :owned_organizations, class: :'TrackIt::Organization', key: :owner_id

    many_to_one         :organization

    many_to_many        :teams,
                        class: :'TrackIt::Department',
                        join_table: :accounts_departments,
                        left_key: :employee_id, right_key: :department_id

    many_to_many        :managed_projects,
                        class: :'TrackIt::Project',
                        join_table: :accounts_projects,
                        left_key: :manager_id, right_key: :project_id

    many_to_many        :collaborations,
                        class: :'TrackIt::Project',
                        join_table: :accounts_projects_collab,
                        left_key: :collaborator_id, right_key: :project_id

    many_to_many        :positions,
                        class: :'TrackIt::Organization',
                        join_table: :accounts_organizations,
                        left_key: :employee_id, right_key: :employer_id

    # many_to_many        :submitted_issues,
    #                     class: :'TrackIt::Issue',
    #                     join_table: :accounts_submitted_issues,
    #                     left_key: :submitter_id, right_key: :issue_id

    many_to_many        :assigned_issues,
                        class: :'TrackIt::Issue',
                        join_table: :accounts_issues,
                        left_key: :assignee_id, right_key: :issue_id

    plugin              :association_dependencies,
                        owned_organizations: :destroy,
                        submitted_comments: :destroy,
                        submitted_issues: :destroy,
                        teams: :nullify,
                        managed_projects: :nullify,
                        collaborations: :nullify,
                        positions: :nullify,
                        assigned_issues: :nullify

    plugin              :whitelist_security
    plugin              :timestamps, update_on_create: true

    set_allowed_columns :first_name, :last_name, :email, :password, :role, :picture

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
          first_name:,
          last_name:,
          email:,
          role:,
          picture:
        }, options
      )
    end
  end
end
