# frozen_string_literal: true

module TrackIt
  # Service object to add a project to an organization
  class AddProjectToOrganization
    def self.call(organization_id:, project_id:)
      organization = Organization.first(id: organization_id)
      project = Project.first(id: project_id)

      organization.add_project(project)
    end
  end
end
