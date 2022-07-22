# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Account Handling' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      TrackIt::Account.create(account_data)
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    account = TrackIt::Account.first
    _(account.first_name).must_equal 'Daniel Thierry'
    _(account.last_name).must_equal 'Marcelin'
    _(account.email).must_equal 'marcelinthierry@gmail.com'
    _(account.role).must_equal 'super'
  end
end
