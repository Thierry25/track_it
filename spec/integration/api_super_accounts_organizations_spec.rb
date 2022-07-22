# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Account Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  describe 'Account information' do
    it 'HAPPY: should be able to get details of a single account' do
      account_data = DATA[:accounts][1]
      account = TrackIt::Account.create(account_data)

      get "/api/v1/accounts/#{account.email}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['id']).must_equal account.id
      _(result['first_name']).must_equal account.first_name
      _(result['last_name']).must_equal account.last_name
      _(result['role']).must_equal account.role
      _(result['email']).must_equal account.email
      _(result['salt']).must_be_nil
      _(result['password']).must_be_nil
      _(result['password_hash']).must_be_nil
    end
  end

  describe 'Super Account Creation and owned organizations' do
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @data = DATA[:accounts][1].merge(DATA[:organizations][1])
    end

    it 'HAPPY: should be able to create super accounts and owned organization' do
      post 'api/v1/super/accounts', @data.to_json, @req_header

      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      org = JSON.parse(last_response.body)['org']
      acc = JSON.parse(last_response.body)['acc']

      account = TrackIt::Account.first
      organization = TrackIt::Organization.first

      _(acc['id']).must_equal account.id
      _(acc['first_name']).must_equal @data['first_name']
      _(acc['last_name']).must_equal @data['last_name']
      _(acc['email']).must_equal @data['email']
      _(acc['role']).must_equal @data['role']
      _(account.password?(@data['password'])).must_equal true
      _(account.password?('Para Siempre')).must_equal false

      _(org['id']).must_equal organization.id
      _(org['identifier']).must_equal @data['identifier']
      _(org['name']).must_equal @data['name']
      _(org['country']).must_equal @data['country']
    end
  end
end
