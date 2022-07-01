# frozen_string_literal: true

require 'roda'
require 'json'

module TrackIt
  # Web controller for TrackIt API
  class Api < Roda
    plugin :halt

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'TrackItAPI up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      routing.on @api_root do
        routing.on 'projects' do
          @proj_route = "#{@api_root}/projects"

          routing.on String do |proj_id|
            routing.on 'issues' do
              @issue_route = "#{@api_root}/projects/#{proj_id}/issues"
              # GET api/v1/projects/[proj_id]/issues/[issue_id]
              routing.get String do |issue_id|
                issue = Issue.where(project_id: proj_id, id: issue_id).first
                issue ? issue.to_json : raise('Issue not found')
              rescue StandardError => e
                routing.halt 404, { message: e.message }.to_json
              end

              # GET api/v1/projects/[proj_id]/issues
              routing.get do
                output = { data: Project.first(id: proj_id).issues }
                JSON.pretty_generate(output)
              rescue StandardError
                routing.halt 404, message: 'Could not find issues'
              end

              # POST api/v1/projects/[ID]/issues
              routing.post do
                new_data = JSON.parse(routing.body.read)
                proj = Project.first(id: proj_id)
                new_issue = proj.add_issue(new_data)
                raise 'Could not save document' unless new_issue

                response.status = 201
                response['Location'] = "#{@issue_route}/#{new_issue.id}"
                { message: 'Issue saved', data: new_issue }.to_json

              rescue Sequel::MassAssignmentRestriction
                Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
                routing.halt 400, { message: 'Illegal Attributes' }.to_json
              rescue StandardError
                routing.halt 500, { message: 'Database error' }.to_json
              end
            end

            # GET api/v1/projects/[ID]
            routing.get do
              proj = Project.first(id: proj_id)
              proj ? proj.to_json : raise('Project not found')
            rescue StandardError => e
              routing.halt 404, { message: e.message }.to_json
            end
          end

          # GET api/v1/projects
          routing.get do
            output = { data: Project.all }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find projects' }.to_json
          end

          # POST api/v1/projects
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_proj = Project.new(new_data)
            raise('Could not save project') unless new_proj.save

            response.status = 201
            response['Location'] = "#{@proj_route}/#{new_proj.id}"
            { message: 'Project saved', data: new_proj }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Attributes' }.to_json
          rescue StandardError => e
            routing.halt 400, { message: e.message }.to_json
          end
        end
      end
    end
  end
end
