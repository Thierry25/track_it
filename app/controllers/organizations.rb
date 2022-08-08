# frozen_string_literal: true

require 'roda'
require_relative './app'

module TrackIt
  # Web Controller for TrackIt API
  class Api < Roda
    route('organizations') do |routing|
      @organization_route = "#{@api_root}/organizations"

      routing.on String do |organization_id|
        @organization_id = organization_id
        routing.multi_route

        # GET api/v1/organizations/[organization_ID]
        routing.get do
          organization = Organization.first(id: organization_id)
          organization ? organization.to_json : raise('Organization not found')

        rescue StandardError => e
          routing.halt 404, { message: e.message }.to_json
        end
      end

      # GET api/v1/organizations
      # Will return a list of organizations
      routing.is do
        routing.get do
          output = { data: Organization.all }
          JSON.pretty_generate(output)
        rescue StandardError
          routing.halt 404, { message: 'Could not find organizations' }.to_json
        end

        routing.post do
          new_data = JSON.parse(routing.body.read)
          # Will be changed later
          new_organization = TrackIt::Organization.create(new_data)
          raise('Could not save organization') unless new_organization.save

          response.status = 201
          response['Location'] = "#{@organization_route}/#{new_organization.id}"
          { message: 'Organization saved', data: new_organization }.to_json
        rescue Sequel::MassAssignmentRestriction
          Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
          routing.halt 400, { message: 'Illegal Attributes' }.to_json
        rescue StandardError => e
          Api.logger.error "UNKOWN ERROR: #{e.message}"
          routing.halt 500, { message: 'Unknown server error' }.to_json
        end
      end
    end
  end
end
