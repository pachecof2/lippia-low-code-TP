@Workspace @TPFinal
Feature: Workspace

  Background:
    Given base url https://api.clockify.me/api/v1
    And header x-api-key = MmI5NjMxNGQtNjJkNS00NDc1LWI3NGMtZWYwMmM2ZDA3ZjQx

  @GetWorkspaceId
  Scenario: Get Workspace
    And endpoint /workspaces
    When execute method GET
    Then the status code should be 200
    And response should be [0].name = Fabiolapacheco555's workspace
    * define workspaceId = response[0].id