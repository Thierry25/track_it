# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test comment handling' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      TrackIt::Account.create(account_data)
    end
  end

  it 'HAPPY: should retrieve correct information from DB' do
    comment_data = DATA[:comments][1]
    acc = TrackIt::Account.first
    new_comment = acc.add_submitted_comment(comment_data)

    comment = TrackIt::Comment.first(id: new_comment.id)
    _(comment.content).must_equal comment_data['content']
  end
end
