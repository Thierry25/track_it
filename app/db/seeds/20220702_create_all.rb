# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, projects, issues'
    create_accounts
    create_managed_projects
    create_issues
    add_collaborators
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
MANAGER_INFO = YAML.load_file("#{DIR}/managers_projects.yml")
PROJ_INFO = YAML.load_file("#{DIR}/projects_seed.yml")
ISSUES_INFO = YAML.load_file("#{DIR}/issues_seed.yml")
CONTRIB_INFO = YAML.load_file("#{DIR}/projects_collaborators.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    TrackIt::Account.create(account_info)
  end
end

def create_managed_projects
  MANAGER_INFO.each do |manager|
    account = TrackIt::Account.first(username: manager['username'])
    manager['proj_name'].each do |proj_name|
      proj_data = PROJ_INFO.find { |proj| proj['name'] == proj_name }
      TrackIt::CreateProjectForManager.call(
        manager_id: account.id, project_data: proj_data
      )
    end
  end
end

def create_issues
  issue_info_each = ISSUES_INFO.each
  projects_cycle = TrackIt::Project.all.cycle
  loop do
    issue_info = issue_info_each.next
    project = projects_cycle.next
    TrackIt::CreateIssueForProject.call(
      project_id: project.id, issue_data: issue_info
    )
  end
end

def add_collaborators
  contrib_info = CONTRIB_INFO
  contrib_info.each do |contrib|
    proj = TrackIt::Project.first(name: contrib['proj_name'])
    contrib['collaborator_email'].each do |email|
      TrackIt::AddCollaboratorToProject.call(
        email:, project_id: proj.id
      )
    end
  end
end
