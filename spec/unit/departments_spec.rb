# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Department Handling' do
  before do
    wipe_database

    DATA[:organizations].each do |org|
      TrackIt::Organization.create(org)
    end
  end

  it 'should retrieve correct data from DB' do
    department_data = DATA[:departments][1]
    organization = TrackIt::Organization.first
    new_department = organization.add_department(department_data)

    department = TrackIt::Department.find(id: new_department.id)
    _(department.name).must_equal department_data['name']
  end
end
