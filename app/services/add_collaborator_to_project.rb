# frozen_string_literal: true

module TrackIt
  # Service object to add collaborator to a project
  class AddCollaboratorToProject
    # Error Project Manager cannot be a collaborator
    class AccountNotCollaborator < StandardError
      def message = 'Account cannot be a collaborator'
    end

    def self.call(project_id:, email:)
      collaborator = Account.first(email:)
      project = Project.first(id: project_id)
      department = project.department

      raise(AccountNotCollaborator) if owner?(collaborator,
                                              department) || !employee?(collaborator,
                                                                        department) || (role?(
                                                                          collaborator, department
                                                                        ) != 3 && role?(collaborator, department) != 4)

      project.add_collaborator(collaborator)
    end

    def self.owner?(collaborator, department)
      return true if department.organization.owner.id == collaborator.id
    end

    def self.employee?(collaborator, department)
      is_there = false
      collaborator.teams.each do |team|
        if team.id == department.id
          is_there = true
          break
        end
      end
      is_there
    end

    def self.role?(collaborator, department)
      user = nil
      department.employees.each do |employee|
        if employee.id == collaborator.id
          user = employee
          break
        end
      end
      user.values[:role_id] if user
    end

    private_class_method :owner?, :employee?, :role?
  end
end
