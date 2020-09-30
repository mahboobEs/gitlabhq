# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Releases (JavaScript fixtures)' do
  include ApiHelpers
  include JavaScriptFixturesHelpers

  let_it_be(:admin) { create(:admin) }
  let_it_be(:project) { create(:project, :repository, path: 'releases-project') }

  let_it_be(:milestone_12_3) do
    create(:milestone,
           project: project,
           title: '12.3',
           description: 'The 12.3 milestone',
           start_date: Time.zone.parse('2018-12-10'),
           due_date: Time.zone.parse('2019-01-10'))
  end

  let_it_be(:milestone_12_4) do
    create(:milestone,
           project: project,
           title: '12.4',
           description: 'The 12.4 milestone',
           start_date: Time.zone.parse('2019-01-10'),
           due_date: Time.zone.parse('2019-02-10'))
  end

  let_it_be(:open_issues_12_3) do
    create_list(:issue, 2, milestone: milestone_12_3, project: project)
  end

  let_it_be(:closed_issues_12_3) do
    create_list(:issue, 3, :closed, milestone: milestone_12_3, project: project)
  end

  let_it_be(:open_issues_12_4) do
    create_list(:issue, 3, milestone: milestone_12_4, project: project)
  end

  let_it_be(:closed_issues_12_4) do
    create_list(:issue, 1, :closed, milestone: milestone_12_4, project: project)
  end

  let_it_be(:release) do
    create(:release,
           :with_evidence,
           milestones: [milestone_12_3, milestone_12_4],
           project: project,
           tag: 'v1.1',
           name: 'The first release',
           description: 'Best. Release. **Ever.** :rocket:',
           created_at: Time.zone.parse('2018-12-3'),
           released_at: Time.zone.parse('2018-12-10'))
  end

  let_it_be(:other_link) do
    create(:release_link,
           release: release,
           name: 'linux-amd64 binaries',
           filepath: '/binaries/linux-amd64',
           url: 'https://downloads.example.com/bin/gitlab-linux-amd64')
  end

  let_it_be(:runbook_link) do
    create(:release_link,
           release: release,
           name: 'Runbook',
           url: "#{release.project.web_url}/runbook",
           link_type: :runbook)
  end

  let_it_be(:package_link) do
    create(:release_link,
           release: release,
           name: 'Package',
           url: 'https://example.com/package',
           link_type: :package)
  end

  let_it_be(:image_link) do
    create(:release_link,
           release: release,
           name: 'Image',
           url: 'https://example.com/image',
           link_type: :image)
  end

  after(:all) do
    remove_repository(project)
  end

  describe API::Releases, type: :request do
    before(:all) do
      clean_frontend_fixtures('api/releases/')
    end

    it 'api/releases/release.json' do
      get api("/projects/#{project.id}/releases/#{release.tag}", admin)

      expect(response).to be_successful
    end
  end

  graphql_query_path = 'releases/queries/all_releases.query.graphql'

  describe "~/#{graphql_query_path}", type: :request do
    include GraphqlHelpers

    before(:all) do
      clean_frontend_fixtures('graphql/releases/')
    end

    it "graphql/#{graphql_query_path}.json" do
      query = File.read(File.join(Rails.root, '/app/assets/javascripts', graphql_query_path))

      post_graphql(query, current_user: admin, variables: { fullPath: project.full_path })

      expect_graphql_errors_to_be_empty
    end
  end
end
