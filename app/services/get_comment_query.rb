# frozen_string_literal: true

module TrackIt
  # Service object to determine if an account can see a comment
  class GetCommentQuery
    # Error for account does not have access to see comment
    class ForbiddenError < StandardError
      def message
        'You are not allowed to see this comment'
      end
    end

    # Error for cannot find a comment
    class NotFoundError < StandardError
      def message
        'We could not find this comment'
      end
    end

    def self.call(requestor:, comment:)
      raise NotFoundError unless comment

      policy = CommentPolicy.new(requestor, comment)
      raise ForbiddenError unless policy.can_view?

      comment.full_details.merge(policies: policy.summary)
    end
  end
end
