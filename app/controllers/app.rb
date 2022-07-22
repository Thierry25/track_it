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
        routing.on 'accounts' do
          routing.on String do |email|
            # GET api/v1/accounts/[email]
            routing.get do
              account = Account.find(email:)
              account ? account.to_json : raise('Account not found')
            rescue StandardError
              routing.halt 404, { message: error.message }.to_json
            end
          end
        end

        routing.on 'super' do
          routing.on('accounts') do
            @account_route = "#{@api_root}/super/accounts"

            # POST api/v1/super/accounts
            routing.post do
              new_data = JSON.parse(routing.body.read)
              # Those information will be passed to a service later
              account_data = {
                first_name: new_data['first_name'],
                last_name: new_data['last_name'],
                email: new_data['email'],
                picture: new_data['picture'],
                password: new_data['password']
              }

              organization_data = {
                identifier: new_data['identifier'],
                name: new_data['name'],
                logo: new_data['logo'],
                country: new_data['country']
              }
              # This account has a SUPER role in the DB
              new_account = Account.new(account_data)
              raise('Could not save account') unless new_account.save

              new_organization = new_account.add_owned_organization(organization_data)
              unless new_organization
                new_account.delete
                raise 'Could not save organization'
              end

              response.status = 201
              response['Location'] = "#{@account_route}/#{new_account.id}/organizations/#{new_organization.id}"

              { message: 'Organization and account created', org: new_organization, acc: new_account }.to_json
              # binding.pry

            rescue Sequel::MassAssignmentRestriction
              Api.logger.warn "MASS-ASSIGNMENT:: #{account_data.keys}"
              routing.halt 400, { message: 'Illegal Request' }.to_json
            rescue StandardError => e
              Api.logger.error 'Unknown error saving account'
              routing.halt 500, { message: e.message }.to_json
            end
          end
        end

        routing.on 'organizations' do
          # @organization_route = "#{@api_root}/organizations"

          routing.on String do |organization_id|
            routing.on 'departments' do
              @department_route = "#{@api_root}/organizations/#{organization_id}/departments"

              routing.on String do |department_id|
                # GET api/v1/organizations/[organization_ID]/departments/[department_ID]
                routing.get do
                  department = Department.where(organization_id:, id: department_id).first
                  department ? department.to_json : raise('Department not found')

                rescue StandardError => e
                  routing.halt 404, { message: e.message }.to_json
                end

                routing.on('accounts') do
                  routing.on String do |email|
                    routing.is do
                      # GET api/v1/organizations/[org..ID]/departments/[dep..ID]/accounts/[accont_EM]
                      routing.get do
                        account = Account.where(organization_id:, email:).first
                        account ? account.to_json : raise('Account not found')

                      rescue StandardError => e
                        routing.halt 404, { message: e.message }.to_json
                      end

                      # POST
                    end
                  end
                  # GET api/v1/organizations/[org..ID]/departments/[dep..ID]/accounts
                  routing.get do
                    department = Department.where(organization_id:, id: department_id).first
                    output = { data: department.employees }
                    JSON.pretty_generate(output)
                  rescue StandardError
                    routing.halt 404, { message: 'Could not find accounts within this department' }.to_json
                  end

                  # POST api/v1/organizations/[org..ID]/departments/[dep..ID]/accounts
                  routing.post do
                    new_data = JSON.parse(routing.body.read)
                    department = Department.where(organization_id:, id: department_id)
                    # email or id? -> id feels better // To check afterwards // or create a secret and secure identifier
                    account = Account.first(email: new_data['email'])

                    employee = department.add_employee(account)
                    raise('Could not add account to department') unless employee

                    response.status = 201
                    # response['Location'] =
                    { message: 'Employee added to department', data: employee }.to_json
                  end
                end

                routing.on('projects') do
                  @proj_route = "#{@api_root}/organizations/#{organization_id}/departments/#{department_id}/projects"

                  routing.on String do |project_id|
                    # GET api/v1/organizations/[organization_ID]/departments/[department_ID]/projects/[project_ID]

                    routing.on('issues') do
                      # GET api/v1/organizations/[org.._ID]/departments/[dep.._ID]/projects/[pro.._ID]/issues

                      routing.get do
                        project = Project.where(department_id:, id: project_id).first
                        output = { data: project.issues }
                        JSON.pretty_generate(output)
                      rescue StandardError
                        routing.halt 404, { message: 'Could not find issues related to this project' }.to_json
                      end

                      # THIS IS THE CODE THAT WILL ALLOW USERS TO POST ISSUES
                      # THERE IS A WAY TO KNOW WHO IS THE AUTHENTICATED USER
                      # WILL THEN BE ABLE TO FIND THE ACCOUNT_ID
                      # routing.post do
                      #   new_data = JSON.parse(routing.body.read)
                      #   project = Project.where(department_id:, id: project_id).first

                      #   account = Account.first(id: whatever)
                      #   account.add_submitted_issue(new_data)
                      #   project.add_issue(issue)
                      # end
                    end

                    routing.get do
                      project = Project.where(department_id:, id: project_id).first
                      project ? project.to_json : raise('Project not found')

                    rescue StandardError => e
                      routing.halt 404, { message: e.message }.to_json
                    end
                  end
                  # GET api/v1/organizations/[organization_ID]/departments/[department_ID]/projects
                  routing.get do
                    department = Department.where(organization_id:, id: department_id).first
                    output = { data: department.projects }
                    JSON.pretty_generate(output)
                  rescue StandardError
                    routing.halt 404, { message: 'Could not find projects within department' }.to_json
                  end

                  # POST api/v1/organizations/[organization_ID]/departments/[department_ID]/projects
                  routing.post do
                    new_data = JSON.parse(routing.body.read)
                    department = Department.where(organization_id:, id: department_id).first

                    proj = department.add_new_project(new_data)
                    raise('Could not save project') unless proj.save

                    response.status = 201
                    response['Location'] = "#{@proj_route}/#{proj.id}"
                    { message: 'Project successfully created', data: proj }.to_json
                  rescue Sequel::MassAssignmentRestriction
                    Api.logger.warn "MASS-ASSIGNMENT:: #{new_data.keys}"
                    routing.halt 400, { message: 'Illegal Request' }.to_json
                  rescue StandardError => e
                    Api.logger.error 'Unknown error saving project'
                    routing.halt 500, { message: e.message }.to_json
                  end
                end
              end

              # GET api/v1/organizations/[organization_id]/departments
              routing.get do
                organization = Organization.first(id: organization_id)
                output = { data: organization.departments }
                JSON.pretty_generate(output)
              rescue StandardError
                routing.halt 404, { message: 'Could not find departments' }.to_json
              end

              routing.post do
                # POST api/v1/organizations/[organization_ID]/departments
                department_data = JSON.parse(routing.body.read)
                organization = Organization.first(id: organization_id)
                new_department = organization.add_department(department_data)

                raise('Could not save department') unless new_department

                response.status = 201
                response['Location'] = "#{@department_route}/#{new_department.id}"
                { message: 'Department saved', data: new_department }.to_json
              rescue Sequel::MassAssignmentRestriction
                Api.logger.warn "MASS-ASSIGNMENT: #{department_data.keys}"
                routing.halt 400, { message: 'Illegal attributes' }.to_json
              rescue StandardError
                routing.halt 500, { message: error.message }.to_json
              end
            end

            # GETting/POSTing accounts to an organization
            routing.on 'accounts' do
              # GET api/v1/organizations/[organization_ID]/accounts
              @account_route = "#{@api_root}/organizations/#{organization_id}/accounts"
              routing.get do
                organization = Organization.first(id: organization_id)
                output = { data: organization.employees }
                JSON.pretty_generate(output)
              rescue StandardError
                routing.halt 404, { message: 'Could not find employees within organization' }.to_json
              end

              routing.post do
                # POST api/v1/organizations/[organization_ID]/accounts
                new_data = JSON.parse(routing.body.read)
                organization = Organization.first(id: organization_id)
                new_account = organization.add_employee(new_data)

                raise('Could not save employee') unless new_account

                response.status = 201
                response['Location'] = "#{@account_route}/#{new_account.id}"
                { message: 'Account saved to organization', data: new_account }.to_json
              rescue Sequel::MassAssignmentRestriction
                Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
                routing.halt 400, { message: 'Illegal attributes' }.to_json
              rescue StandardError
                routing.halt 500, { message: error.message }.to_json
              end
            end

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
          end
        end
      end
    end
  end
end
