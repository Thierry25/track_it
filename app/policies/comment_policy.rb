# frozen_string_literal: true

module TrackIt
  # Policy to determine comment access by account
  class CommentPolicy
    def initialize(requestor, comment)
      @requestor = requestor
      @comment = comment
    end

    def can_view?
      self_request? || proj_collaborator? || proj_manager? || assigned? || organization_owner?
    end

    def can_edit?
      self_request?
    end

    def can_delete?
      self_request?
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?
      }
    end

    private

    def self_request?
      @requestor == @comment.submitter
    end

    def proj_collaborator?
      proj = @comment.related_projects.first
      proj.collaborators.include? @requestor if proj
    end

    def proj_manager?
      proj = @comment.related_projects.first
      proj.managers.include? @requestor if proj
    end

    def assigned?
      issue = @comment.related_issues.first
      issue.assignees.include? @requestor if issue
    end

    def organization_owner?
      proj = @comment.related_projects.first
      issue = @comment.related_issues.first
      owner = if proj
                proj.department.organization.owner
              else
                issue.projects.first.department.organization.owner
              end

      @requestor == owner
    end
  end
end

#   def dep_admin?
#     proj = @comment.related_projects.first
#     issue = @comment.related_issues.first
#     data = proj.nil? ? issue.projects.first.department : proj.department
#     if employee?(@requestor, data)

#     end
#   end

#   def employee?(collaborator, department)
#       is_there = false
#       collaborator.teams.each do |team|
#         if team.id == department.id
#           is_there = true
#           break
#         end
#       end
#       is_there
#     end
