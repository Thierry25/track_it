# frozen_string_literal: true

module TrackIt
  # Service to add all developers and testers of a department as collaborators of project
  class AddAllCollaborators
    # Error account cannot be a collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add this account as collaborator'
      end
    end

    def self.call(account:, project:, department_id:)
      department = Department.first(id: department_id)
      devs = department.soft_devs&.map do |soft_dev|
        TrackIt::AddCollaborator.call(
          account:, project:, collaborator_email: soft_dev.email
        )
      end
      testers = department.testers&.map do |tester|
        TrackIt::AddCollaborator.call(
          account:, project:, collaborator_email: tester.email
        )
      end
      devs.concat(testers)
    end
  end
end
