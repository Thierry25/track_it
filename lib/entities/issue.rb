# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module TrackIt
  module Entity
    class Issue < Dry::Struct
      include Dry.types

      attribute :id,           Strict::Integer
      attribute :types,        Strict::String
      attribute :assigned_to,  Account
      attribute :status,       Strict::String
      attribute :description,  Strict::String
      attribute :created_at,   Strict::DateTime
    end
  end
end
