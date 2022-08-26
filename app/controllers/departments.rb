# frozen_string_literal: true

require 'roda'
require_relative './app'
require_relative './organizations'

module TrackIt
  # Web Controller for TrackIt API
  class Api < Roda
    route('departments') do |routing|
      routing.halt 403, { message: 'Not authorized' }.to_json unless @auth_account

      @department_route = "#{@api_root}/organizations/#{@organization_id}/departments"

      routing.on String do |department_id|
        @department_id = department_id
        @req_department = Department.first(id: department_id)
        routing.multi_route
        # GET api/v1/organizations/[organization_ID]/departments/[department_ID]

        routing.is do
          routing.get do
            department = GetDepartmentQuery.call(
              requestor: @auth_account, department: @req_department
            )
            { data: department }.to_json
          rescue GetDepartmentQuery::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue GetDepartmentQuery::NotFoundError => e
            routing.halt 404, { message: e.message }.to_json
          rescue StandardError => e
            puts "GET DEPARTMENT ERROR: #{e.inspect}"
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        routing.on('employees') do
          # PUT api/v1/organizations/[ID]/departments/[ID]/employees
          routing.put do
            req_data = JSON.parse(routing.body.read)

            employee = AddEmployee.call(
              account: @auth_account,
              department_id:,
              employee_email: req_data['email'],
              role_id: req_data['role']
            )

            { data: employee }.to_json
          rescue AddEmployee::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end

          # DELETE api/v1/organizations/[ID]/departments/[ID]/employees
          routing.delete do
            req_data = JSON.parse(routing.body.read)

            employee = RemoveEmployee.call(
              account: @auth_account,
              department: @req_department,
              employee_email: req_data['email']
            )

            { message: "#{employee.username} removed from department",
              data: employee }.to_json
          rescue RemoveEmployee::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        routing.on('admins') do
          routing.put do
            req_data = JSON.parse(routing.body.read)

            admin = AddAdmin.call(
              account: @auth_account,
              department_id:,
              admin_email: req_data['email']
            )

            { data: admin }.to_json
          rescue AddAdmin::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end

          routing.delete do
            req_data = JSON.parse(routing.body.read)

            admin = RemoveAdmin.call(
              account: @auth_account,
              department: @req_department,
              admin_email: req_data['email']
            )
            { message: "#{admin.username} removed from department",
              data: admin }.to_json
          rescue RemoveAdmin::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end
      end

      routing.post do
        # POST api/v1/organizations/[organization_ID]/departments
        new_department = CreateDepartment.call(
          account: @auth_account,
          organization: @req_organization,
          department_data: JSON.parse(routing.body.read)
        )

        response.status = 201
        response['Location'] = "#{@department_route}/#{new_department.id}"
        { message: 'Department saved', data: new_department }.to_json
      rescue CreateDepartment::ForbiddenError => e
        routing.halt 403, { message: e.message }.to_json
      rescue CreateDepartment::IllegalRequestError => e
        routing.halt 400, { message: e.message }.to_json
      rescue StandardError => e
        Api.logger.warn "Could not create department: #{e.message}"
        routing.halt 500, { message: 'API server error' }.to_json
      end
    end
  end
end
