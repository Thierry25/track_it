# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, organizations, departments, projects, issues and comments'
    create_super_accounts
    create_owned_organizations
    create_departments
    create_projects
    create_accounts
    create_issues
    create_comments
    # many_to_many
    add_managed_projects
    add_collaborators
    add_assigned_issues
    add_employees_to_department
    add_issues_to_project
    add_comments_to_issue
    add_comments_to_project

    # add_project_to_organization
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
DEPARTM_PROJ_INFO = YAML.load_file("#{DIR}/departments_projects.yml")
EMPLOYEE_INFO = YAML.load_file("#{DIR}/employees_departments.yml")
EMPLOYEE_ORG_INFO = YAML.load_file("#{DIR}/employees_organizations.yml")
ISSUE_COMMENT_INFO = YAML.load_file("#{DIR}/issues_comments.yml")
MANAGER_INFO = YAML.load_file("#{DIR}/managers_projects.yml")
ORG_DEPARTMENT_INFO = YAML.load_file("#{DIR}/organizations_departments.yml")
OWNER_INFO = YAML.load_file("#{DIR}/owners_organizations.yml")
CONTRIB_INFO = YAML.load_file("#{DIR}/projects_collaborators.yml")
PROJ_COMMENT_INFO = YAML.load_file("#{DIR}/projects_comments.yml")
PROJ_ISSUE_INFO = YAML.load_file("#{DIR}/projects_issues.yml")
COMMENT_SUBMITTER_INFO = YAML.load_file("#{DIR}/submitters_comments.yml")
ISSUE_SUBMITTER_INFO = YAML.load_file("#{DIR}/submitters_issues.yml")

def create_super_accounts
  ACCOUNTS_INFO.each do |account_info|
    TrackIt::Account.create(account_info) if account_info['role'] == 'super'
  end
end

def create_owned_organizations
  OWNERS_INFO.each do |owner|
    account = TrackIt::Account.first(email: owner['email'])
    owner['organization_name'].each do |org_name|
      organization_data = ORGANIZATIONS_INFO.find { |org| org['name'] == org_name }
      TrackIt::CreateOrganizationForOwner.call(
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
      TrackIt::CreateDepartmentForOrganization.call(
        organization_id: organization.id, department_data:
      )
    end
  end
end

def create_projects
  DEPARTM_PROJ_INFO.each do |dep|
    department = TrackIt::Department.first(name: dep['dep_name'])
    dep['proj_name'].each do |project|
      project_data = PROJ_INFO.find { |proj| proj['name'] == project }
      TrackIt::CreateProjectForDepartment.call(
        department_id: department.id, project_data:
      )
    end
  end
end

def create_accounts
  EMPLOYEE_ORG_INFO.each do |org_info|
    organization = TrackIt::Organization.first(name: org_info['organization_name'])
    org_info['employee_email'].each do |account|
      account_data = ACCOUNTS_INFO.find { |acc| acc['email'] == account }
      TrackIt::CreateEmployeeForOrganization.call(
        organization_id: organization.id, account_data:
      )
    end
  end
end

def create_issues
  ISSUE_SUBMITTER_INFO.each do |issue_info|
    account = TrackIt::Account.first(email: issue_info['submitter_email'])
    issue_info['ticket_number'].each do |issue|
      issue_data = ISSUES_INFO.find { |iss| iss['ticket_number'] == issue }
      TrackIt::CreateIssueForSubmitter.call(
        submitter_id: account.id, issue_data:
      )
    end
  end
end

def create_comments
  COMMENT_SUBMITTER_INFO.each do |comment_info|
    # binding.pry
    account = TrackIt::Account.first(email: comment_info['submitter_email'])
    comment_info['content'].each do |comment|
      comment_data = COMMENTS_INFO.find { |comm| comm['content'] == comment }
      # binding.pry
      TrackIt::CreateCommentForSubmitter.call(
        submitter_id: account.id, comment_data:
      )
    end
  end
end

def add_managed_projects
  MANAGER_INFO.each do |management|
    project = TrackIt::Project.first(name: management['proj_name'])
    management['manager_email'].each do |email|
      TrackIt::AddManagedProjectForManager.call(
        email:, project_id: project.id
      )
    end
  end
end

def add_collaborators
  CONTRIB_INFO.each do |contrib|
    project = TrackIt::Project.first(name: contrib['proj_name'])
    contrib['collaborator_email'].each do |email|
      TrackIt::AddCollaboratorToProject.call(
        email:, project_id: project.id
      )
    end
  end
end

def add_assigned_issues
  ASSIGN_INFO.each do |assign|
    issue = TrackIt::Issue.first(ticket_number: assign['ticket_number'])
    assign['assignee_email'].each do |email|
      TrackIt::AssignIssueToAccount.call(
        issue_id: issue.id, email:
      )
    end
  end
end

def add_employees_to_department
  EMPLOYEE_INFO.each do |emp|
    department = TrackIt::Department.first(name: emp['team_name'])
    emp['employee_email'].each do |email|
      TrackIt::AddEmployeeToDepartment.call(
        department_id: department.id, email:
      )
    end
  end
end

def add_issues_to_project
  PROJ_ISSUE_INFO.each do |info|
    project = TrackIt::Project.first(name: info['project_name'])
    info['ticket_number'].each do |issue|
      issue = TrackIt::Issue.first(ticket_number: issue)
      TrackIt::AddIssueToProject.call(
        project_id: project.id, issue_id: issue.id
      )
    end
  end
end

def add_comments_to_issue
  ISSUE_COMMENT_INFO.each do |iss_com|
    issue = TrackIt::Issue.first(ticket_number: iss_com['ticket_number'])
    iss_com['comment_content'].each do |com|
      comment = TrackIt::Comment.first(content: com)
      TrackIt::AddCommentToIssue.call(
        issue_id: issue.id, comment_id: comment.id
      )
    end
  end
end

def add_comments_to_project
  PROJ_COMMENT_INFO.each do |proj_com|
    proj = TrackIt::Project.first(name: proj_com['proj_name'])
    proj_com['comment_content'].each do |com|
      comment = TrackIt::Comment.first(content: com)
      TrackIt::AddCommentToProject.call(
        project_id: proj.id, comment_id: comment.id
      )
    end
  end
end
