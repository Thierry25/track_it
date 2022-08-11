# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Project Handling' do
  before do
    wipe_database

    DATA[:departments].each do |department|
      TrackIt::Department.create(department)
    end
  end

  it 'HAPPY: retrieve correct information from DB' do
    project_data = DATA[:projects][1]
    department = TrackIt::Department.first
    new_project = department.add_project(project_data)

    project = TrackIt::Project.find(id: new_project.id)
    _(project.name).must_equal project_data['name']
    _(project.description).must_equal project_data['description']
    _(project.url).must_equal project_data['url']
  end

  it 'SECURITY: should use deterministic integers' do
    project_data = DATA[:projects][1]
    department = TrackIt::Department.first
    new_project = department.add_project(project_data)

    _(new_project.id.is_a?(Numeric)).must_equal true
  end

  it 'SECURITY: should secure sensitive information' do
    project_data = DATA[:projects][1]
    department = TrackIt::Department.first
    new_project = department.add_project(project_data)

    saved_proj = app.DB[:projects].first
    _(saved_proj[:description_secure]).wont_equal new_project.description
    _(saved_proj[:url_secure]).wont_equal new_project.url
  end
end
