# frozen_string_literal: true

module TrackIt
  # Service Object to add a project to the list of managed projects
  class AddManagedProjectForManager
    # Cannot add this account as project manager
    class AccountNotProjectManagerError < StandardError
      def message = 'This account cannot be a project manager'
    end

    def self.call(email:, project_id:)
      manager = Account.first(email:)
      project = Project.first(id: project_id)
      department = project.department

      # binding.pry
      raise(AccountNotProjectManagerError) if owner?(manager,
                                                     department) || !employee?(manager,
                                                                               department) || role?(
                                                                                 manager, department
                                                                               ) != 2

      manager.add_managed_project(project)
    end

    def self.owner?(manager, department)
      department.organization.owner.id == manager.id
    end

    def self.employee?(manager, department)
      is_there = false
      manager.teams.each do |team|
        if team.id == department.id
          is_there = true
          break
        end
      end
      is_there
    end

    def self.role?(manager, department)
      user = nil
      department.employees.each do |employee|
        if employee.id == manager.id
          user = employee
          break
        end
      end
      user.values[:role_id] if user
    end

    private_class_method :owner?, :employee?, :role?
  end
end
