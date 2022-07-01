# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Issue Handling' do
  before do
    wipe_database

    DATA[:projects].each do |project_data|
      TrackIt::Project.create(project_data)
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    issue_data = DATA[:issues][1]
    proj = TrackIt::Project.first
    new_issue = proj.add_issue(issue_data)

    issue = TrackIt::Issue.find(id: new_issue.id)
    _(issue.type).must_equal issue_data['type']
    _(issue.priority).must_equal issue_data['priority']
    _(issue.status).must_equal issue_data['status']
    _(issue.description).must_equal issue_data['description']
    _(issue.title).must_equal issue_data['title']
  end

  it 'SECURITY: should not use deterministic integers' do
    issue_data = DATA[:issues][1]
    proj = TrackIt::Project.first
    new_issue = proj.add_issue(issue_data)

    _(new_issue.id.is_a?(Numeric)).must_equal false
  end

  it 'SECURITY: should secure sensitive attributes' do
    issue_data = DATA[:issues][1]
    proj = TrackIt::Project.first
    new_issue = proj.add_issue(issue_data)
    stored_issue = app.DB[:issues].first

    _(stored_issue[:description_secure]).wont_equal new_issue.description
    _(stored_issue[:title_secure]).wont_equal new_issue.title
  end
end
