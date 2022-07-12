# frozen_string_literal: true

module TrackIt
  # Service Object to add a project to the list of managed projects
  class AddManagedProjectForManager
    def self.call(project_id:, email:)
      manager = Account.first(email:)
      project = Project.first(id: project_id)

      manager.add_managed_project(project)
    end
  end
end
