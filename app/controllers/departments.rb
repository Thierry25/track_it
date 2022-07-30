# frozen_string_literal: true

require 'roda'
require_relative './app'
require_relative './organizations'

module TrackIt
  # Web Controller for TrackIt API
  class Api < Roda
    route('departments') do |routing|
      @department_route = "#{@api_root}/organizations/#{@organization_id}/departments"

      routing.on String do |department_id|
        @department_id = department_id
        routing.multi_route
        # GET api/v1/organizations/[organization_ID]/departments/[department_ID]
        routing.get do
          department = Department.where(organization_id: @organization_id, id: department_id).first
          department ? department.to_json : raise('Department not found')

        rescue StandardError => e
          routing.halt 404, { message: e.message }.to_json
        end
      end

      # GET api/v1/organizations/[organization_id]/departments
      routing.get do
        organization = Organization.first(id: @organization_id)
        output = { data: organization.departments }
        JSON.pretty_generate(output)
      rescue StandardError
        routing.halt 404, { message: 'Could not find departments' }.to_json
      end

      routing.post do
        # POST api/v1/organizations/[organization_ID]/departments
        department_data = JSON.parse(routing.body.read)
        organization = Organization.first(id: @organization_id)
        new_department = organization.add_department(department_data)

        raise('Could not save department') unless new_department

        response.status = 201
        response['Location'] = "#{@department_route}/#{new_department.id}"
        { message: 'Department saved', data: new_department }.to_json
      rescue Sequel::MassAssignmentRestriction
        Api.logger.warn "MASS-ASSIGNMENT: #{department_data.keys}"
        routing.halt 400, { message: 'Illegal attributes' }.to_json
      rescue StandardError => e
        routing.halt 500, { message: e.message }.to_json
      end
    end
  end
end
