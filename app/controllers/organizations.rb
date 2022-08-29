# frozen_string_literal: true

require 'roda'
require_relative './app'

module TrackIt
  # Web Controller for TrackIt API
  class Api < Roda
    route('organizations') do |routing|
      unauthorized_message = { message: 'Unauthorized Request' }.to_json
      routing.halt(403, unauthorized_message) unless @auth_account

      @organization_route = "#{@api_root}/organizations"

      routing.on String do |organization_id|
        @organization_id = organization_id
        @req_organization = Organization.first(id: organization_id)
        routing.multi_route

        # GET api/v1/organizations/[organization_ID]
        routing.get do
          organization = GetOrganizationQuery.call(
            requestor: @auth_account, organization: @req_organization
          )

          { data: organization }.to_json
        rescue GetOrganizationQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetOrganizationQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "FIND ORGANIZATION ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end

      routing.is do
        # GET api/v1/organizations
        # Will return a list of organizations
        routing.get do
          organizations = OrganizationPolicy::AccountScope.new(@auth_account).viewable
          JSON.pretty_generate(data: organizations)
        rescue StandardError
          routing.halt 403, { message: 'Could not find organizations' }.to_json
        end

        routing.post do
          new_data = JSON.parse(routing.body.read)
          # Will be changed later
          new_organization = @auth_account.add_owned_organization(new_data)

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
