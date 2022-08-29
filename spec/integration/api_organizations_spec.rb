# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Testing Organizations Handling' do
  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = TrackIt::Account.create(@account_data)
    @wrong_account = TrackIt::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting organizations' do
    describe 'Getting list of organizations' do
      before do
        @account.add_owned_organization(DATA[:organizations][0])
        @account.add_owned_organization(DATA[:organizations][1])
      end

      it 'HAPPY: Should get a list of organizations for authorized account' do
        header 'AUTHORIZATION', auth_header(@account_data)

        get 'api/v1/organizations'
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 2
      end

      it 'BAD: Should not proceed without authorization' do
        get 'api/v1/organizations'
        _(last_response.status).must_equal 403

        result = JSON.parse last_response.body
        _(result['data']).must_be_nil
      end
    end

    it 'HAPPY: should get details about a single organization' do
      org = @account.add_owned_organization(DATA[:organizations][0])

      header 'AUTHORIZATION', auth_header(@account_data)
      get "api/v1/organizations/#{org.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data']['attributes']

      _(result['id']).must_equal org.id
      _(result['identifier']).must_equal org.identifier
      _(result['name']).must_equal org.name
      _(result['logo']).must_equal org.logo
      _(result['country']).must_equal org.country
    end

    it 'SAD: should return error if unknown organization requested' do
      header 'AUTHORIZATION', auth_header(@account_data)

      get 'api/v1/organizations/foobar'

      _(last_response.status).must_equal 404

      result = JSON.parse last_response.body
      _(result['data']).must_be_nil
    end

    it 'SAD: should not get details without authorization' do
      org = @account.add_owned_organization(DATA[:organizations][0])

      get "api/v1/organizations/#{org.id}"
      _(last_response.status).must_equal 403

      result = JSON.parse last_response.body
      _(result['data']).must_be_nil
    end

    it 'BAD WRONG AUTHORIZATION: should not get details with wrong authorization' do
      org = @account.add_owned_organization(DATA[:organizations][0])

      header 'AUTHORIZATION', auth_header(@wrong_account_data)

      get "api/v1/organizations/#{org.id}"
      _(last_response.status).must_equal 403

      result = JSON.parse last_response.body
      _(result['data']).must_be_nil
    end

    it 'BAD SQL VULNERABILITY: should prevent basic SQL injection of id' do
      @account.add_owned_organization(DATA[:organizations][0])
      @account.add_owned_organization(DATA[:organizations][1])

      header 'AUTHORIZATION', auth_header(@account_data)
      get 'api/v1/organizations/2%20or%20id%3E0'

      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Create New Organizations' do
    before do
      @organization_data = DATA[:organizations][2]
    end

    it 'HAPPY: should be able to create new organizations' do
      header 'AUTHORIZATION', auth_header(@account_data)

      post 'api/v1/organizations', @organization_data.to_json

      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      org = TrackIt::Organization.first

      _(created['id']).must_equal org.id
      _(created['identifier']).must_equal @organization_data['identifier']
      _(created['name']).must_equal @organization_data['name']
      _(created['logo']).must_equal @organization_data['logo']
      _(created['country']).must_equal @organization_data['country']
    end

    it 'SAD: Should not create new organization without authorization' do
      post 'api/v1/organizations', @organization_data.to_json

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
      _(last_response.body['data']).must_be_nil
    end

    it 'SECURITY: Should not create organization with mass assignment' do
      bad_data = @organization_data.clone
      bad_data['created_at'] = '1900-01-01'

      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/organizations', bad_data.to_json

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
