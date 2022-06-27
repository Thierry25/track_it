# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module TrackIt
  module Entity
    class Account < Dry::Struct
      include Dry.types

      attribute :username       Strict::String
      attribute :email          Strict::String
      attribute :picture        String.optional
    end
  end
end
