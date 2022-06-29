# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'

module TrackIt
  STORE_DIR = 'app/db/store'

  # Holds a full secret issue
  class Issue
    # Create a new issue by passing in hash of attributes
    def initialize(new_issue)
      @id          = new_issue['id'] || new_id
      @type        = new_issue['type']
      @priority    = new_issue['priority']
      @status      = new_issue['status']
      @description = new_issue['description']
      @title       = new_issue['title']
    end

    attr_reader :id, :type, :priority, :status, :description, :title

    def to_json(options = {})
      JSON(
        {
          mode: 'issue',
          id:,
          type:,
          priority:,
          status:,
          description:,
          title:
        },
        options
      )
    end

    # File store must be setup once when application runs
    def self.setup
      Dir.mkdir(TrackIt::STORE_DIR) unless Dir.exist? TrackIt::STORE_DIR
    end

    # Stores document in file store
    def save
      File.write("#{TrackIt::STORE_DIR}/#{id}.txt", to_json)
    end

    # Query method to find one document
    def self.find(find_id)
      issue_file = File.read("#{TrackIt::STORE_DIR}/#{find_id}.txt")
      Issue.new JSON.parse(issue_file)
    end

    # Query method to retrieve index of all documents
    def self.all
      Dir.glob("#{TrackIt::STORE_DIR}/*.txt").map do |file|
        file.match(%r{#{Regexp.quote(TrackIt::STORE_DIR)}/(.*)\.txt})[1]
      end
    end

    private

    def new_id
      timestamp = Time.now.to_f.to_s
      Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..9]
    end
  end
end
