# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test remove employee' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      TrackIt::Account.create(account_data)
    end

    @owner = TrackIt::Account.first
    @admin = TrackIt::Account.all[2]
    @proj_manager = TrackIt::Account.all[3]
    @soft_dev = TrackIt::Account.all[4]
    @tester = TrackIt::Account.all[5]

    @org = @owner.add_owned_organization(DATA[:organizations][1])
    @dep = @org.add_department(DATA[:departments][1])

    TrackIt::AddEmployee.call(
      account: @owner, department_id: @dep.id, employee_email: @proj_manager.email, role_id: 2
    )
  end

  it 'HAPPY: owner should be able to remove employee' do
    _(@dep.employees.count).must_equal 1
    _(@dep.employees.first.email).must_equal @proj_manager.email

    TrackIt::RemoveEmployee.call(
      account: @owner, department: @dep, employee_email: @proj_manager.email
    )

    _(@dep.employees.count).must_equal 0
  end

  it 'HAPPY: admin should be able to remove employee' do
    TrackIt::AddAdmin.call(
      account: @owner, department_id: @dep.id, admin_email: @admin.email
    )
    _(@dep.employees.count).must_equal 2
    _(@dep.admins.first.email).must_equal @admin.email

    TrackIt::RemoveEmployee.call(
      account: @admin, department: @dep, employee_email: @proj_manager.email
    )

    _(@dep.employees.count).must_equal 1
    _(@dep.employees.first.email).must_equal @admin.email
  end

  it 'SAD: non-employee should not be able to remove employee' do
    _(proc {
      TrackIt::RemoveEmployee.call(
        account: @soft_dev, department: @dep, employee_email: @proj_manager.email
      )
    }).must_raise TrackIt::RemoveEmployee::ForbiddenError
  end

  it 'SAD: soft_dev should not be able to remove employee' do
    TrackIt::AddEmployee.call(
      account: @owner, department_id: @dep.id, employee_email: @soft_dev.email, role_id: 3
    )
    _(proc {
      TrackIt::RemoveEmployee.call(
        account: @soft_dev, department: @dep, employee_email: @proj_manager.email
      )
    }).must_raise TrackIt::RemoveEmployee::ForbiddenError
  end

  it 'SAD: tester should not be able to remove employee' do
    TrackIt::AddEmployee.call(
      account: @owner, department_id: @dep.id, employee_email: @tester.email, role_id: 4
    )
    _(proc {
      TrackIt::RemoveEmployee.call(
        account: @tester, department: @dep, employee_email: @proj_manager.email
      )
    }).must_raise TrackIt::RemoveEmployee::ForbiddenError
  end

  it 'SAD: proj manager should not be able to remove employee' do
    TrackIt::AddEmployee.call(
      account: @owner, department_id: @dep.id, employee_email: @tester.email, role_id: 4
    )
    _(proc {
      TrackIt::RemoveEmployee.call(
        account: @proj_manager, department: @dep, employee_email: @tester.email
      )
    }).must_raise TrackIt::RemoveEmployee::ForbiddenError
  end
end
