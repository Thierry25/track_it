# frozen_string_literal: true

module TrackIt
  # Policy to determine project's access by account
  class ProjectPolicy
    def initialize(account, project)
      @account = account
      @project = project
    end

    def can_view?
      account_is_owner? || account_is_collaborator? || account_is_project_manager? || account_is_admin?
    end

    def can_edit?
      account_is_owner? || account_is_project_manager? || account_is_admin?
    end

    def can_delete?
      account_is_owner? || account_is_project_manager? || account_is_admin?
    end

    def can_add_managers?
      (account_is_owner? || account_is_admin?) && no_manager?
    end

    def can_remove_managers?
      account_is_owner? || account_is_admin?
    end

    def can_add_collaborators?
      account_is_owner? || account_is_project_manager? || account_is_admin?
    end

    def can_remove_collaborators?
      account_is_owner? || account_is_project_manager? || account_is_admin?
    end

    # TO BE UPDATED IF NEEDED
    def can_add_issues?
      # Role 1 - admin, 2 - Project Manager, 3 - Developer, 4 - Tester
      account_is_project_manager? || account_is_soft_dev? || account_is_tester?
    end

    def can_remove_issues?
      account_is_project_manager?
    end

    def can_add_comments?
      account_is_owner? || account_is_collaborator? || account_is_project_manager? || account_is_admin?
    end

    def can_collaborate?
      !(account_is_owner? || account_is_collaborator? || account_is_project_manager? || account_is_admin? || account_is_manager?) && account_is_employee?
      # && role? != 1 && role? != 2
    end

    def can_manage?
      !(account_is_owner? || account_is_collaborator? || account_is_admin? || account_is_project_manager?) && account_is_manager?
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_add_managers: can_add_managers?,
        can_remove_managers: can_remove_managers?,
        can_add_collaborators: can_add_collaborators?,
        can_remove_collaborators: can_remove_collaborators?,
        can_add_issues: can_add_issues?,
        can_remove_issues: can_remove_issues?,
        can_add_comments: can_add_comments?,
        can_collaborate: can_collaborate?,
        can_manage: can_manage?
      }
    end

    private

    def account_is_owner?
      @project.department.organization.owner == @account
    end

    def account_is_collaborator?
      @project.collaborators&.include? @account
    end

    def account_is_project_manager?
      @project.managers&.include? @account
    end

    def no_manager?
      @project.managers&.count&.zero?
    end

    def account_is_employee?
      is_there = false
      @account.teams&.each do |team|
        if team.id == @project.department.id
          is_there = true
          break
        end
      end
      is_there
    end

    def account_is_admin?
      @project.department.admins&.map(&:id)&.include? @account.id
    end

    def account_is_manager?
      @project.department.project_managers&.map(&:id)&.include? @account.id
    end

    def account_is_soft_dev?
      @account.developing_at&.map(&:id)&.include? @project.department.id
      # @project.department.soft_devs&.map(&:id)&.include? @account.id
    end

    def account_is_tester?
      @account.testing_at&.map(&:id)&.include? @project.department.id
      # @project.department.testers&.map(&:id)&.include? @account.id
    end
  end
end
