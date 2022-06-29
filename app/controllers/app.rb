# frozen_string_literal: true

require 'roda'
require 'json'

require_relative '../models/issue'

module TrackIt
  # Web controller for TrackIt API
  class Api < Roda
    plugin :environments
    plugin :halt

    configure do
      Issue.setup
    end

    route do |routing| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'application/json'

      routing.root do
        response.status = 200
        { message: 'TrackItAPI up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          routing.on 'issues' do
            # GET api/v1/issues/[id]
            routing.get String do |id|
              response.status = 200
              Issue.find(id).to_json
            rescue StandardError
              routing.halt 404, { message: 'Issue not found' }.to_json
            end

            # GET api/v1/issues
            routing.get do
              response.status = 200
              output = { issues_ids: Issue.all }
              JSON.pretty_generate(output)
            end

            # POST api/v1/issues
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_issue = Issue.new(new_data)

              if new_issue.save
                response.status = 201
                { message: 'Issue saved', id: new_issue.id }.to_json
              else
                routing.halt 400, { message: 'Could not save issue' }.to_json
              end
            end
          end
        end
      end
    end
  end
end
