# TrackIt

API to store and retrieve organizations, projects, and issues submitted by an account.

## Routes

All routes return JSON

- GET `/`: Root route shows if Web API is running
- POST `api/v1/accounts`: Create a new account
- GET `api/v1/accounts/[username]`: Get account details
- POST `api/v1/organizations`: Create a new organization
- GET `api/v1/organizations/[ID]`: Get organization information
- POST `api/v1/organizations/[ID]/departments`: Create a new department within an organization
- GET `api/v1/organizations/[ID]/departments/[ID]`: Get department information
- POST `api/v1/organizations/[ID]/departments/[ID]/projects`: Create a new project within an department
- GET `api/v1/organizations/[ID]/departments/[ID]/projects/[ID]`: Get project information
- POST `api/v1/organizations/[ID/departmens/[ID]/projects/[ID]/comments`: Create a new comment related to a project
- GET `api/v1/organizations/[ID/departmens/[ID]/projects/[ID]/comments/[ID]`: Get comment information
- POST `api/v1/organizations/[ID/departmens/[ID]/projects/[ID]/issues`: Create a new issue regarding a project
- GET `api/v1/organizations/[ID/departmens/[ID]/projects/[ID]/issues/[ID]`: Get issue information
- POST `api/v1/organizations/[ID/departmens/[ID]/projects/[ID]/issues/[ID]/comments`: Create a new comment for an issue
- GET `api/v1/organizations/[ID/departmens/[ID]/projects/[ID]/issues/[ID]/comments/[ID]`: Get comment information

## Install

Install this API by cloning the _relevant branch_ and use bundler to install specified gems from `Gemfile.lock`:

```shell
bundle install
```

Setup development database once:

```shell
rake db:migrate
```

## Test

Setup test database once:

```shell
RACK_ENV=test rake db:migrate
```

Run the test specification script in `Rakefile`:

```shell
rake spec
```

## Develop/Debug

Add fake data to the development database to work on this project:

```shell
rake db:seed
```

## Execute

Launch the API using:

```shell
rake run:dev
```

## Release check

Before submitting pull requests, please check if specs, style, and dependency audits pass (will need to be online to update dependency database):

```shell
rake release
```
