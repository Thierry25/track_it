# frozen_string_literal: true

module TrackIt
  # Service object to create a new project for a PM
  class CreateProjectForManager
    def self.call(manager_id:, project_data:)
      Account.find(id: manager_id).add_managed_projects(project_data)
    end
  end
end
