# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Testing Organizations Handling' do
  before do
    wipe_database
  end

  describe 'Getting organizations' do
    it 'HAPPY: Should return a list of organizations' do
      TrackIt::Organization.create(DATA[:organizations][0])
      TrackIt::Organization.create(DATA[:organizations][1])

      get 'api/v1/organizations'
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 2
    end

    it 'HAPPY: Should be able to get details about a single organization' do
      existing_org = DATA[:organizations][1]
      TrackIt::Organization.create(existing_org)
      id = TrackIt::Organization.first.id

      get "api/v1/organizations/#{id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data']['attributes']['id']).must_equal id
      _(result['data']['attributes']['name']).must_equal existing_org['name']
      _(result['data']['attributes']['country']).must_equal existing_org['country']
      _(result['data']['attributes']['identifier']).must_equal existing_org['identifier']
    end

    it 'SAD: Should return error if unknown organization asked' do
      get '/api/v1/organizations/foobar'

      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      TrackIt::Organization.create(name: 'New Organization', identifier: 'L0L-007', country: 'Taiwan')
      TrackIt::Organization.create(name: 'Newer Organization', identifier: 'Pool_Party', country: 'Jamaica')

      get 'api/v1/organizations/2%20or%20id%3E0'

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end
end
