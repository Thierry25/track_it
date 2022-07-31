# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  TrackIt::Comment.map(&:destroy)
  TrackIt::Issue.map(&:destroy)
  TrackIt::Project.map(&:destroy)
  TrackIt::Department.map(&:destroy)
  TrackIt::Organization.map(&:destroy)
  TrackIt::Account.map(&:destroy)
end

DATA = {
  accounts: YAML.load(File.read('app/db/seeds/accounts_seed.yml')),
  organizations: YAML.load(File.read('app/db/seeds/organizations_seed.yml')),
  departments: YAML.load(File.read('app/db/seeds/departments_seed.yml')),
  projects: YAML.load(File.read('app/db/seeds/projects_seed.yml')),
  issues: YAML.load(File.read('app/db/seeds/issues_seed.yml')),
  comments: YAML.load(File.read('app/db/seeds/comments_seed.yml'))
}.freeze
