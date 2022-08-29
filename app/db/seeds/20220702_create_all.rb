# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, organizations, departments, projects, issues and comments'
    create_accounts
    create_owned_organizations
    create_departments
    add_employees_to_department
    add_admins_to_department
    create_projects
    add_managed_projects
    add_collaborators
    create_issues
    add_assigned_issues
    create_projects_comments
    create_issues_comments
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
ORGANIZATIONS_INFO = YAML.load_file("#{DIR}/organizations_seed.yml")
DEPARTMENTS_INFO = YAML.load_file("#{DIR}/departments_seed.yml")
OWNERS_INFO = YAML.load_file("#{DIR}/owners_organizations.yml")
PROJ_INFO = YAML.load_file("#{DIR}/projects_seed.yml")
ISSUES_INFO = YAML.load_file("#{DIR}/issues_seed.yml")
COMMENTS_INFO = YAML.load_file("#{DIR}/comments_seed.yml")
# -
ASSIGN_INFO = YAML.load_file("#{DIR}/accounts_assigned_issues.yml")
ADMIN_INFO = YAML.load_file("#{DIR}/admins_departments.yml")
DEPARTM_PROJ_INFO = YAML.load_file("#{DIR}/departments_projects.yml")
EMPLOYEE_INFO = YAML.load_file("#{DIR}/employees_departments.yml")
ISSUE_COMMENT_INFO = YAML.load_file("#{DIR}/issues_comments.yml")
MANAGER_INFO = YAML.load_file("#{DIR}/managers_projects.yml")
ORG_DEPARTMENT_INFO = YAML.load_file("#{DIR}/organizations_departments.yml")
OWNER_INFO = YAML.load_file("#{DIR}/owners_organizations.yml")
CONTRIB_INFO = YAML.load_file("#{DIR}/projects_collaborators.yml")
PROJ_COMMENT_INFO = YAML.load_file("#{DIR}/projects_comments.yml")
PROJ_ISSUE_INFO = YAML.load_file("#{DIR}/projects_issues.yml")
COMMENT_SUBMITTER_INFO = YAML.load_file("#{DIR}/submitters_comments.yml")
ISSUE_SUBMITTER_INFO = YAML.load_file("#{DIR}/submitters_issues.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_data|
    TrackIt::Account.create(account_data)
  end
end

def create_owned_organizations
  OWNERS_INFO.each do |owner|
    account = TrackIt::Account.first(username: owner['username'])
    owner['organization_name'].each do |org_name|
      organization_data = ORGANIZATIONS_INFO.find { |org| org['name'] == org_name }
      TrackIt::CreateOrganization.call(
        owner_id: account.id, organization_data:
      )
    end
  end
end

def create_departments
  ORG_DEPARTMENT_INFO.each do |org|
    organization = TrackIt::Organization.first(name: org['org_name'])
    org['depart_name'].each do |department|
      department_data = DEPARTMENTS_INFO.find { |dp| dp['name'] == department }
      account = organization.owner
      TrackIt::CreateDepartment.call(
        account:, organization:, department_data:
      )
    end
  end
end

def add_employees_to_department
  EMPLOYEE_INFO.each do |emp|
    # binding.pry
    department = TrackIt::Department.first(name: emp['team_name'])
    account = department.organization.owner
    emp['data'].each do |data|
      TrackIt::AddEmployee.call(
        account:, department_id: department.id, employee_email: data['email'], role_id: data['role_id']
      )
    end
  end
end

def add_admins_to_department
  ADMIN_INFO.each do |admin_info|
    department = TrackIt::Department.first(name: admin_info['team_name'])
    account = department.organization.owner
    TrackIt::AddAdmin.call(
      account:, department_id: department.id, admin_email: admin_info['email']
    )
  end
end

def create_projects
  DEPARTM_PROJ_INFO.each do |dep|
    department = TrackIt::Department.first(name: dep['dep_name'])
    dep['proj_name'].each do |project|
      project_data = PROJ_INFO.find { |proj| proj['name'] == project }
      account = department.organization.owner
      TrackIt::CreateProject.call(
        account:, department:, project_data:
      )
    end
  end
end

def add_managed_projects
  MANAGER_INFO.each do |management|
    project = TrackIt::Project.first(name: management['proj_name'])
    account = project.department.organization.owner
    management['manager_email'].each do |email|
      TrackIt::AddManager.call(
        account:, project:, manager_email: email
      )
    end
  end
end

def add_collaborators
  CONTRIB_INFO.each do |contrib|
    project = TrackIt::Project.first(name: contrib['proj_name'])
    account = project.department.organization.owner
    contrib['collaborator_email'].each do |email|
      # binding.pry
      TrackIt::AddCollaborator.call(
        account:, project:, collaborator_email: email
      )
    end
  end
end

def create_issues
  ISSUE_SUBMITTER_INFO.each do |issue_info|
    account = TrackIt::Account.first(email: issue_info['submitter_email'])
    project = TrackIt::Project.first(name: issue_info['project_name'])
    issue_info['ticket_number'].each do |issue|
      issue_data = ISSUES_INFO.find { |iss| iss['ticket_number'] == issue }
      TrackIt::CreateIssue.call(
        account:, project:, issue_data:
      )
    end
  end
end

def add_assigned_issues
  ASSIGN_INFO.each do |assign|
    issue = TrackIt::Issue.first(ticket_number: assign['ticket_number'])
    account = issue.projects.first.managers.first
    assign['assignee_email'].each do |email|
      TrackIt::AssignIssue.call(
        account:, issue:, assignee_email: email
      )
    end
  end
end

def create_projects_comments
  COMMENT_SUBMITTER_INFO.each do |comment_info|
    # binding.pry
    account = TrackIt::Account.first(email: comment_info['submitter_email'])
    project = TrackIt::Project.first(name: comment_info['project_name'])
    comment_info['content'].each do |comment|
      comment_data = COMMENTS_INFO.find { |comm| comm['content'] == comment }
      # binding.pry
      TrackIt::CreateComment.call(
        account:, project:, comment_data:
      )
    end
  end
end

def create_issues_comments
  ISSUE_COMMENT_INFO.each do |iss_com|
    account = TrackIt::Account.first(email: iss_com['submitter_email'])
    issue = TrackIt::Issue.first(ticket_number: iss_com['ticket_number'])
    iss_com['content'].each do |comment|
      comment_data = COMMENTS_INFO.find { |comm| comm['content'] == comment }
      TrackIt::CreateIssueComment.call(
        account:, issue:, comment_data:
      )
    end
  end
end
