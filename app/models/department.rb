# frozen_string_literal: true

require 'sequel'
require 'json'

module TrackIt
  # Models a department within a organization
  class Department < Sequel::Model
    many_to_one :organization

    # one_to_many :projects, class: :'TrackIt::Project', key: :department_id
    one_to_many :projects

    plugin :timestamps, update_on_create: true
    plugin :whitelist_security

    set_allowed_columns :name
  end
end
