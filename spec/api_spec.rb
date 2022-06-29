# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require 'yaml'
require 'pry'

require_relative '../app/controllers/app'
require_relative '../app/models/issue'

def app
  TrackIt::Api
end

DATA = YAML.safe_load File.read('app/db/seeds/issue_seeds.yml')

describe 'Test TrackIt Web API' do
  include Rack::Test::Methods

  before do
    # Wipe database before each test
    Dir.glob("#{TrackIt::STORE_DIR}/*.txt").each { |filename| FileUtils.rm(filename) }
  end

  it 'should find the root route' do
    get '/'
    _(last_response.status).must_equal 200
  end

  describe 'Handle issues' do
    it 'HAPPY: should be able to get list of all issues' do
      TrackIt::Issue.new(DATA[0]).save
      TrackIt::Issue.new(DATA[1]).save

      get 'api/v1/issues'
      result = JSON.parse last_response.body
      _(result['issues_ids'].count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single issue' do
      TrackIt::Issue.new(DATA[1]).save
      # binding.pry
      id = Dir.glob("#{TrackIt::STORE_DIR}/*.txt").first.split(%r{[/.]})[3]

      get "/api/v1/issues/#{id}"
      result = JSON.parse last_response.body

      _(last_response.status).must_equal 200
      _(result['id']).must_equal id
    end

    it 'SAD: should return error if unknown issue requested' do
      get '/api/v1/issues/foobar'

      _(last_response.status).must_equal 404
    end

    it 'HAPPY: should be able to create new issues' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post 'api/v1/issues', DATA[1].to_json, req_header

      _(last_response.status).must_equal 201
    end
  end
end
