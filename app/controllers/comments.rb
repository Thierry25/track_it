# frozen_string_literal: true

require_relative './app'

module TrackIt
  # Web Controller for TrackIt API
  class Api < Roda
    route('comments') do |routing|
      routing.halt 403, { message: 'Not authorized' }.to_json unless @auth_account

      @comment_route = "#{@api_root}/comments"

      routing.on String do |comment_id|
        # GET api/v1/comments/[ID]
        @req_comment = Comment.first(id: comment_id)
        routing.get do
          comment = GetCommentQuery.call(
            requestor: @auth_account, comment: @req_comment
          )
          { data: comment }.to_json
        rescue GetCommentQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetCommentQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "GET COMMENT ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
  end
end
