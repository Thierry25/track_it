# frozen_string_literal: true

require_relative './app'

module TrackIt
  # Web Controller for TrackIt API
  class Api < Roda
    route('issues') do |routing|
      routing.halt 403, { message: 'Not authorized' }.to_json unless @auth_account

      @issue_route = "#{@api_root}/issues"

      routing.on String do |issue_id|
        @req_issue = Issue.find(id: issue_id)
        # GET api/v1/issues/[ID]
        routing.get do
          issue = GetIssueQuery.call(
            requestor: @auth_account, issue: @req_issue
          )
          { data: issue }.to_json
        rescue GetIssueQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetIssueQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "GET COMMENT ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API Server Error' }.to_json
        end
      end
    end
  end
end
