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
        # routing.on 'departments' do
        #   @department_route = "#{@api_root}/organizations/#{organization_id}/departments"

        #   routing.on String do |department_id|
        #     routing.on('projects') do
        #       @proj_route = "#{@api_root}/organizations/#{organization_id}/departments/#{department_id}/projects"

        #       routing.on String do |project_id|
        #         # GET api/v1/organizations/[org..ID]/departments/[dep..ID]/projects/[pro..ID]
        #         routing.is do
        #           routing.get do
        #             project = Project.where(department_id:, id: project_id).first
        #             project ? project.to_json : raise('Project not found')

        #           rescue StandardError => e
        #             routing.halt 404, { message: e.message }.to_json
        #           end
        #         end

        #         routing.on('comments') do
        #           routing.on String do |comment_id|
        #             # GET api/v1/organizations/[o.ID]/de..s/[d.ID]/pr..s/[p.ID]/comments/[com..ID]
        #             routing.get do
        #               comment = TrackIt::Comment.first(id: comment_id)
        #               comment ? comment.to_json : raise('Comment not found')
        #             rescue StandardError => e
        #               routing.halt 404, { message: e.message }.to_json
        #             end
        #           end

        #           routing.get do
        #             # GET api/v1/organizations/[o.ID]/de..s/[d.ID]/pr..s/[p.ID]/comments/

        #             project = TrackIt::Project.where(department_id:, id: project_id).first
        #             output = { data: project.comments }
        #             JSON.pretty_generate(output)
        #           rescue StandardError
        #             routing.halt 404, { message: 'Could not find comments related to this project' }.to_json
        #           end

        #           routing.post do
        #             # THIS IS THE CODE THAT WILL ALLOW USERS TO POST COMMENTS TO A PROJECT
        #             # THERE IS A WAY TO KNOW WHO IS THE AUTHENTICATED USER
        #             # WILL THEN BE ABLE TO FIND THE ACCOUNT_ID
        #             # routing.post do
        #             #   new_data = JSON.parse(routing.body.read)
        #             #   project = Comment.first(id: project_id)

        #             #   account = Account.first(id: whatever)
        #             #   comment = account.add_submitted_comment(new_data)
        #             #   if comment.saved?
        #             #     project.add_comment(comment)
        #             # end
        #           end
        #         end

        #         routing.on('issues') do
        #           @issue_route = "#{@api_root}/organizations/#{organization_id}/departments/#{department_id}/projects/issues"

        #           routing.on String do |issue_id|
        #             routing.is do
        #               # GET api/v1/organizations/[org..ID]/departments/[dep..ID]/projects/[pro..ID]/issues/[iss..ID]
        #               routing.get do
        #                 issue = TrackIt::Issue.first(id: issue_id)
        #                 issue ? issue.to_json : raise('Issue not found')
        #               rescue StandardError => e
        #                 routing.halt 404, { message: e.message }.to_json
        #               end
        #             end

        #             routing.on('comments') do
        #               routing.on String do |comment_id|
        #                 # GET api/v1/organizations/[o.ID]/de..s/[d.ID]/pr..s/[p.ID]/issues/[iss..ID]/co..ts/[com..ID]
        #                 routing.get do
        #                   # binding.pry
        #                   comment = TrackIt::Comment.first(id: comment_id)
        #                   comment ? comment.to_json : raise('Comment not found')
        #                 rescue StandardError => e
        #                   routing.halt 404, { message: e.message }.to_json
        #                 end
        #               end

        #               # GET api/v1/organizations/[org..ID]/departments/[dep..ID]/projects/[pro..ID]/issues/[iss..ID]/comments
        #               routing.get do
        #                 issue = Issue.first(id: issue_id)
        #                 output = { data: issue.comments }
        #                 JSON.pretty_generate(output)

        #               rescue StandardError
        #                 routing.halt 404,
        #                              { message: 'Could not find issues related to this issue' }.to_json
        #               end

        #               # THIS IS THE CODE THAT WILL ALLOW USERS TO POST COMMENTS TO AN ISSUE
        #               # THERE IS A WAY TO KNOW WHO IS THE AUTHENTICATED USER
        #               # WILL THEN BE ABLE TO FIND THE ACCOUNT_ID
        #               # routing.post do
        #               #   new_data = JSON.parse(routing.body.read)
        #               #   issue = Issue.first(id: issue_id)

        #               #   account = Account.first(id: whatever)
        #               #   comment = account.add_submitted_comment(new_data)
        #               #   if issue.saved?
        #               #     issue.add_comment(comment)
        #               # end
        #             end
        #           end

        #           routing.get do
        #             # GET api/v1/organizations/[org..ID]/departments/[dep..ID]/projects/[pro..ID]/issues
        #             project = Project.where(department_id:, id: project_id).first
        #             output = { data: project.issues }
        #             JSON.pretty_generate(output)
        #           rescue StandardError
        #             routing.halt 404,
        #                          { message: 'Could not find issues related to this project' }.to_json
        #           end

        #           ## THIS IS THE CODE THAT WILL ALLOW USERS TO POST ISSUES
        #           ## THERE IS A WAY TO KNOW WHO IS THE AUTHENTICATED USER
        #           ## WILL THEN BE ABLE TO FIND THE ACCOUNT_ID
        #           ## TO BE CHANGED LATER
        #           routing.post do
        #             # ALLOW USERS TO UPLOAD ISSUES FOR TESTING PURPOSES
        #             # project = Project.where(department_id:, id: project_id).first

        #             #   account = Account.first(id: whatever)
        #             #   issue = account.add_submitted_issue(new_data)
        #             #   if issue.saved?
        #             #     project.add_issue(issue)
        #             new_data = JSON.parse(routing.body.read)
        #             new_issue = TrackIt::Issue.new(new_data)
        #             raise('Could not save issue') unless new_issue.save

        #             response.status = 201
        #             response['Location'] = "#{@issue_route}/#{new_issue.id}"
        #             { message: 'Project saved', data: new_issue }.to_json
        #           rescue Sequel::MassAssignmentRestriction
        #             Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
        #             routing.halt 400, { message: 'Illegal Attributes' }.to_json
        #           rescue StandardError => e
        #             Api.logger.error "UNKOWN ERROR: #{e.message}"
        #             routing.halt 500, { message: 'Unknown server error' }.to_json
        #           end
        #         end
        #       end
        #       # GET api/v1/organizations/[organization_ID]/departments/[department_ID]/projects
        #       routing.get do
        #         department = TrackIt::Department.where(organization_id:, id: department_id).first
        #         output = { data: department.projects }
        #         JSON.pretty_generate(output)
        #       rescue StandardError
        #         routing.halt 404, { message: 'Could not find projects within department' }.to_json
        #       end

        #       # POST api/v1/organizations/[organization_ID]/departments/[department_ID]/projects
        #       routing.post do
        #         new_data = JSON.parse(routing.body.read)
        #         # binding.pry
        #         department = Department.where(organization_id:, id: department_id).first

        #         proj = department.add_project(new_data)
        #         raise('Could not save project') unless proj.save

        #         response.status = 201
        #         response['Location'] = "#{@proj_route}/#{proj.id}"
        #         { message: 'Project successfully created', data: proj }.to_json
        #       rescue Sequel::MassAssignmentRestriction
        #         Api.logger.warn "MASS-ASSIGNMENT:: #{new_data.keys}"
        #         routing.halt 400, { message: 'Illegal Request' }.to_json
        #       rescue StandardError => e
        #         Api.logger 'Unknown error saving project'
        #         routing.halt 500, { message: e.message }.to_json
        #       end
        #     end
        #     # GET api/v1/organizations/[organization_ID]/departments/[department_ID]
        #     routing.get do
        #       department = Department.where(organization_id:, id: department_id).first
        #       department ? department.to_json : raise('Department not found')

        #     rescue StandardError => e
        #       routing.halt 404, { message: e.message }.to_json
        #     end
        #   end

        #   # GET api/v1/organizations/[organization_id]/departments
        #   routing.get do
        #     organization = Organization.first(id: organization_id)
        #     output = { data: organization.departments }
        #     JSON.pretty_generate(output)
        #   rescue StandardError
        #     routing.halt 404, { message: 'Could not find departments' }.to_json
        #   end

        #   routing.post do
        #     # POST api/v1/organizations/[organization_ID]/departments
        #     department_data = JSON.parse(routing.body.read)
        #     organization = Organization.first(id: organization_id)
        #     new_department = organization.add_department(department_data)

        #     raise('Could not save department') unless new_department

        #     response.status = 201
        #     response['Location'] = "#{@department_route}/#{new_department.id}"
        #     { message: 'Department saved', data: new_department }.to_json
        #   rescue Sequel::MassAssignmentRestriction
        #     Api.logger.warn "MASS-ASSIGNMENT: #{department_data.keys}"
        #     routing.halt 400, { message: 'Illegal attributes' }.to_json
        #   rescue StandardError => e
        #     routing.halt 500, { message: e.message }.to_json
        #   end
        # end

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
