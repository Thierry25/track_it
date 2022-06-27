# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module TrackIt
  module Entity
    class Project < Dry::Struct
      include Dry.types

      attribute :id,              Strict::String
      attribute :name,            Strict::String
      attribute :description,     Strict::String
      attribute :organization,    Strict::String.optional
      attribute :created_at,      Strict::DateTime
    end
  end
end
