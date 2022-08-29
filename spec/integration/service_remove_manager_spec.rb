# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test remove manager' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      TrackIt::Account.create(account_data)
    end

    @owner = TrackIt::Account.first
    @admin = TrackIt::Account.all[2]
    @proj_manager = TrackIt::Account.all[4]
    @soft_dev = TrackIt::Account.all[6]
    @tester = TrackIt::Account.all[8]
    @not_employee = TrackIt::Account.last

    organization_data = DATA[:organizations].first
    department_data = DATA[:departments].first
    project_data = DATA[:projects].first

    @org = @owner.add_owned_organization(organization_data)
    @dep = @org.add_department(department_data)
    @proj = @dep.add_project(project_data)

    TrackIt::AddAdmin.call(
      account: @owner, department_id: @dep.id, admin_email: @admin.email
    )

    TrackIt::AddEmployee.call(
      account: @owner, department_id: @dep.id, employee_email: @proj_manager.email, role_id: 2
    )

    TrackIt::AddEmployee.call(
      account: @owner, department_id: @dep.id, employee_email: @soft_dev.email, role_id: 3
    )

    TrackIt::AddEmployee.call(
      account: @owner, department_id: @dep.id, employee_email: @tester.email, role_id: 4
    )

    @proj.add_collaborator(@soft_dev)
    @proj.add_collaborator(@tester)
    @proj.add_manager(@proj_manager)
  end

  #  account_is_owner? || account_is_admin?

  it 'HAPPY: owner should be able to remove project manager' do
    _(@proj.managers.count).must_equal 1
    _(@proj.managers.first).must_equal @proj_manager

    TrackIt::RemoveManager.call(
      account: @owner, project: @proj, manager_email: @proj_manager.email
    )

    _(@proj.managers.count).must_equal 0
  end

  it 'HAPPY: admin should be able to remove project manager' do
    _(@proj.managers.count).must_equal 1
    _(@proj.managers.first).must_equal @proj_manager

    TrackIt::RemoveManager.call(
      account: @admin, project: @proj, manager_email: @proj_manager.email
    )

    _(@proj.managers.count).must_equal 0
  end

  it 'BAD: should not be able to remove non employee' do
    _(proc {
      TrackIt::RemoveManager.call(
        account: @owner, project: @proj, manager_email: @not_employee.email
      )
    })
  end

  it 'SAD: soft dev should not be able to remove manager' do
    _(proc {
      TrackIt::RemoveManager.call(
        account: @soft_dev, project: @proj, manager_email: @proj_manager.email
      )
    })
  end

  it 'SAD: tester should not be able to remove manager' do
    _(proc {
      TrackIt::RemoveManager.call(
        account: @tester, project: @proj, manager_email: @proj_manager.email
      )
    })
  end
end
