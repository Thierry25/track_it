# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

module TrackIt
  # Models a registered account
  class Account < Sequel::Model
    # TO think more about submitted issues and comments, maybe I'm missing something here
    one_to_many         :submitted_comments, class: :'TrackIt::Comment', key: :submitter_id
    one_to_many         :submitted_issues, class: :'TrackIt::Issue', key: :submitter_id
    one_to_many         :owned_organizations, class: :'TrackIt::Organization', key: :owner_id

    many_to_many        :teams,
                        class: :'TrackIt::Department',
                        join_table: :accounts_departments,
                        left_key: :employee_id, right_key: :department_id,
                        select: [Sequel[:departments].*, Sequel[:accounts_departments][:role_id]]

    many_to_many        :managed_projects,
                        class: :'TrackIt::Project',
                        join_table: :accounts_projects,
                        left_key: :manager_id, right_key: :project_id

    many_to_many        :collaborations,
                        class: :'TrackIt::Project',
                        join_table: :accounts_projects_collab,
                        left_key: :collaborator_id, right_key: :project_id

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
                        assigned_issues: :nullify

    plugin              :whitelist_security
    plugin              :timestamps, update_on_create: true

    set_allowed_columns :first_name, :last_name, :email, :username, :password, :picture, :biography, :linkedin,
                        :instagram, :twitter, :youtube

    def companies
      owned_organizations + teams&.map(&:organization)
    end

    def administrated_departments
      teams&.select do |team|
        team.values[:role_id] == 1
      end
    end

    def managing_at
      teams&.select do |team|
        team.values[:role_id] == 2
      end
    end

    def developing_at
      teams&.select do |team|
        team.values[:role_id] == 3
      end
    end

    def testing_at
      teams&.select do |team|
        team.values[:role_id] == 4
      end
    end

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = TrackIt::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end

    def to_h
      {
        type: 'account',
        attributes: {
          username:,
          first_name:,
          last_name:,
          email:,
          picture:,
          biography:,
          linkedin:,
          twitter:,
          instagram:,
          youtube:,
          created_at:
        }
      }
    end

    def full_details
      to_h.merge(
        relationships: {
          submitted_comments:,
          submitted_issues:,
          owned_organizations:,
          teams:,
          managed_projects:,
          collaborations:,
          assigned_issues:,
          companies:,
          administrated_departments:,
          managing_at:,
          developing_at:,
          testing_at:
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
