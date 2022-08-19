# frozen_string_literal: true

require 'roda'
require_relative './app'
require_relative './organizations'
require_relative './departments'

module TrackIt
  # Web Controller for TrackIt API
  class Api < Roda
    route('projects') do |routing|
      @proj_route = "#{@api_root}/organizations/#{@organization_id}/departments/#{@department_id}/projects"

      routing.on String do |project_id|
        # GET api/v1/organizations/[org..ID]/departments/[dep..ID]/projects/[pro..ID]
        @req_project = Project.first(id: project_id)
        routing.is do
          routing.get do
            project = GetProjectQuery.call(
              requestor: @auth_account, project: @req_project
            )
            { data: project }.to_json
          rescue GetProjectQuery::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue GetProjectQuery::NotFoundError => e
            routing.halt 404, { message: e.message }.to_json
          rescue StandardError => e
            puts "GET PROJECT ERROR: #{e.inspect}"
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        routing.on('managers') do
          # PUT api/v1/organizations/[ID]/departments/[ID]/projects/[proj_id]/managers
          routing.put do
            req_data = JSON.parse(routing.body.read)

            manager = AddManager.call(
              account: @auth_account,
              project: @req_project,
              manager_email: req_data['email']
            )

            { data: manager }.to_json
          rescue AddManager::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API Server error' }.to_json
          end

          routing.delete do
            req_data = JSON.parse(routing.body.read)

            manager = RemoveManager.call(
              account: @auth_account,
              project: @req_project,
              manager_email: req_data['email']
            )

            { data: "#{manager.username} removed as manager" }.to_json
          rescue RemoveManager::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API Server error' }.to_json
          end
        end

        routing.on('collaborators') do
          # PUT api/v1/organizations/[ID]/departments/[ID]/projects/[ID]/collaborators
          routing.put do
            req_data = JSON.parse(routing.body.read)

            collaborator = AddCollaborator.call(
              account: @auth_account,
              project: @req_project,
              collaborator_email: req_data['email']
            )

            { data: collaborator }.to_json
          rescue AddCollaborator::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API Server Error' }.to_json
          end

          routing.delete do
            req_data = JSON.parse(routing.body.read)

            collaborator = RemoveCollaborator.call(
              account: @auth_account,
              project: @req_project,
              collaborator_email: req_data['email']
            )

            { data: collaborator }.to_json
          rescue RemoveCollaborator::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API Server Error' }.to_json
          end
        end

        routing.on('comments') do
          # @comment_route = "#{@api_root}/organizations/#{@organization_id}/departments/#{@department_id}/projects/#{project_id}/comments"

          # routing.on String do |comment_id|
          #   # GET api/v1/organizations/[o.ID]/de..s/[d.ID]/pr..s/[p.ID]/comments/[com..ID]
          #   @req_comment = Comment.first(id: comment_id)
          #   routing.get do
          #     comment = GetCommentQuery.call(
          #       requestor: @auth_account, comment: @req_comment
          #     )
          #     { data: comment }.to_json
          #   rescue GetCommentQuery::ForbiddenError => e
          #     routing.halt 403, { message: e.message }.to_json
          #   rescue GetCommentQuery::NotFoundError => e
          #     routing.halt 404, { message: e.message }.to_json
          #   rescue StandardError => e
          #     puts "GET COMMENT ERROR: #{e.inspect}"
          #     routing.halt 500, { message: 'API server error' }.to_json
          #   end
          # end

          # routing.get do
          #   # GET api/v1/organizations/[o.ID]/de..s/[d.ID]/pr..s/[p.ID]/comments/
          #   project = TrackIt::Project.where(department_id: @department_id, id: project_id).first
          #   output = { data: project.comments }
          #   JSON.pretty_generate(output)
          # rescue StandardError
          #   routing.halt 404, { message: 'Could not find comments related to this project' }.to_json
          # end

          routing.post do
            # CHECK IF USER CAN ADD ADD COMMENT, IF THEY CAN, ADD TO THE PROJECT
            new_comment = CreateComment.call(
              account: @auth_account,
              project: @req_project,
              comment_data: JSON.parse(routing.body.read)
            )
            response.status = 201
            response['Location'] = "#{@comment_route}/#{new_comment.id}"
            { message: 'Comment successfully created', data: new_comment }.to_json
          rescue CreateComment::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue CreateComment::IllegalRequestError => e
            routing.halt 400, { message: e.message }.to_json
          rescue StandardError => e
            Api.logger.warn "Could not create comment: #{e.message}"
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        routing.on('issues') do
          # @issue_route = "#{@api_root}/organizations/#{@organization_id}/departments/#{@department_id}/projects/#{project_id}/issues"

          routing.on String do |issue_id|
            @iss = Issue.first(id: issue_id)

            routing.on('assignments') do
              # PUT GET api/v1/organizations/[org..ID]/departments/[dep..ID]/projects/[pro..ID]/issues/[iss..ID]/assignments
              routing.put do
                req_data = JSON.parse(routing.body.read)

                assignee = AssignIssue.call(
                  account: @auth_account,
                  issue: @iss,
                  assignee_email: req_data['email']
                )

                { data: assignee }.to_json
              rescue AssignIssue::ForbiddenError => e
                routing.halt 403, { message: e.message }.to_json
              rescue StandardError
                routing.halt 500, { message: 'API Server Error' }.to_json
              end

              routing.delete do
                req_data = JSON.parse(routing.body.read)

                assignee = RemoveAssignedIssue.call(
                  account: @auth_account,
                  issue: @iss,
                  assignee_email: req_data['email']
                )

                { data: assignee }.to_json
              rescue RemoveAssignedIssue::ForbiddenError => e
                routing.halt 403, { message: e.message }.to_json
              rescue StandardError
                routing.halt 500, { message: 'API Server Error' }.to_json
              end
            end
            # routing.is do
            #   # GET api/v1/organizations/[org..ID]/departments/[dep..ID]/projects/[pro..ID]/issues/[iss..ID]
            #   routing.get do
            #     issue = GetIssueQuery.call(
            #       requestor: @auth_account, issue: @req_issue
            #     )
            #     { data: issue }.to_json
            #   rescue GetIssueQuery::ForbiddenError => e
            #     routing.halt 403, { message: e.message }.to_json
            #   rescue GetIssueQuery::NotFoundError => e
            #     routing.halt 404, { message: e.message }.to_json
            #   rescue StandardError => e
            #     puts "GET COMMENT ERROR: #{e.inspect}"
            #     routing.halt 500, { message: 'API Server Error' }.to_json
            #   end
            # end

            routing.on('comments') do
              # routing.on String do |comment_id|
              #   # GET api/v1/organizations/[o.ID]/de..s/[d.ID]/pr..s/[p.ID]/issues/[iss..ID]/co..ts/[com..ID]
              #   routing.get do
              #     # binding.pry
              #     comment = TrackIt::Comment.first(id: comment_id)
              #     comment ? comment.to_json : raise('Comment not found')
              #   rescue StandardError => e
              #     routing.halt 404, { message: e.message }.to_json
              #   end
              # end

              # GET api/v1/organizations/[org..ID]/departments/[dep..ID]/projects/[pro..ID]/issues/[iss..ID]/comments
              # routing.get do
              #   issue = Issue.first(id: issue_id)
              #   output = { data: issue.comments }
              #   JSON.pretty_generate(output)

              # rescue StandardError
              #   routing.halt 404,
              #                { message: 'Could not find issues related to this issue' }.to_json
              # end

              # THIS IS THE CODE THAT WILL ALLOW USERS TO POST COMMENTS TO AN ISSUE
              # THERE IS A WAY TO KNOW WHO IS THE AUTHENTICATED USER
              # WILL THEN BE ABLE TO FIND THE ACCOUNT_ID

              routing.post do
                # CHECK IF USER CAN ADD ADD COMMENT, IF THEY CAN, ADD TO THE PROJECT
                new_comment = CreateIssueComment.call(
                  account: @auth_account,
                  issue: @iss,
                  comment_data: JSON.parse(routing.body.read)
                )
                response.status = 201
                response['Location'] = "#{@comment_route}/#{new_comment.id}"
                { message: 'Comment successfully created', data: new_comment }.to_json
              rescue CreateIssueComment::ForbiddenError => e
                routing.halt 403, { message: e.message }.to_json
              rescue CreateIssueComment::IllegalRequestError => e
                routing.halt 400, { message: e.message }.to_json
              rescue StandardError => e
                Api.logger.warn "Could not create comment: #{e.message}"
                routing.halt 500, { message: 'API server error' }.to_json
              end
            end
          end

          # routing.get do
          #   # GET api/v1/organizations/[org..ID]/departments/[dep..ID]/projects/[pro..ID]/issues
          #   project = Project.where(department_id: @department_id, id: project_id).first
          #   output = { data: project.issues }
          #   JSON.pretty_generate(output)
          # rescue StandardError
          #   routing.halt 404,
          #                { message: 'Could not find issues related to this project' }.to_json
          # end

          routing.post do
            new_issue = CreateIssue.call(
              account: @auth_account,
              project: @req_project,
              issue_data: JSON.parse(routing.body.read)
            )

            response.status = 201
            response['Location'] = "#{@issue_route}/#{new_issue.id}"
            { message: 'Issue saved', data: new_issue }.to_json
          rescue CreateIssue::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue CreateIssue::IllegalRequestError => e
            routing.halt 400, { message: e.message }.to_json
          rescue StandardError => e
            Api.logger.warn "Could not create comment: #{e.message}"
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end
      end
      # GET api/v1/organizations/[organization_ID]/departments/[department_ID]/projects
      # routing.get do
      #   department = TrackIt::Department.where(organization_id: @organization_id, id: @department_id).first
      #   output = { data: department.projects }
      #   JSON.pretty_generate(output)
      # rescue StandardError
      #   routing.halt 404, { message: 'Could not find projects within department' }.to_json
      # end

      # POST api/v1/organizations/[organization_ID]/departments/[department_ID]/projects
      # routing.post do
      #   new_project = CreateProject.call(
      #     account: @auth_account,
      #     department: @req_department,
      #     project_data: JSON.parse(routing.body.read)
      #   )

      #   response.status = 201
      #   response['Location'] = "#{@proj_route}/#{new_project.id}"
      #   { message: 'Project successfully created', data: new_project }.to_json
      # rescue CreateProject::ForbiddenError => e
      #   routing.halt 403, { message: e.message }.to_json
      # rescue CreateProject::IllegalRequestError => e
      #   routing.halt 400, { message: e.message }.to_json
      # rescue StandardError => e
      #   Api.logger.warn "Could not create project: #{e.message}"
      #   routing.halt 500, { message: 'API server error' }.to_json
      # end
    end
  end
end
