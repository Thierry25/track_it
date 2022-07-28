# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddComment to issue' do
  before do
    wipe_database

    DATA[:accounts].each do |account|
      TrackIt::Account.create(account)
    end

    DATA[:issues].each do |issue|
      TrackIt::Issue.create(issue)
    end

    @submitter = TrackIt::Account.first
    @issue = TrackIt::Issue.all[0]
    comment_data = DATA[:comments].first

    @comment = TrackIt::CreateCommentForSubmitter.call(
      submitter_id: @submitter.id, comment_data:
    )
  end

  it 'HAPPY: should be able to add comment to issue' do
    TrackIt::AddCommentToIssue.call(
      issue_id: @issue.id, comment_id: @comment.id
    )
    _(@issue.comments.count).must_equal 1
    _(@issue.comments.first).must_equal @comment
  end
end
