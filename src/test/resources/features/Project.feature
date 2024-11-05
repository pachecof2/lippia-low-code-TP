@Projects @TPFinal
Feature: Projects
  Background:
    Given base url https://api.clockify.me/api/v1
    And header Content-Type = application/json


  @Projects @GetProjects
  Scenario: Get all projects
    And header x-api-key = MmI5NjMxNGQtNjJkNS00NDc1LWI3NGMtZWYwMmM2ZDA3ZjQx
    And endpoint /workspaces/67182d64ab5dd152ad9aa1c6/projects
    When execute method GET
    Then the status code should be 200
    * define projectId = response[0].id
    * define projectName = response[0].name

  @Projects @UpdateProject
  Scenario: Update a Project
    And header x-api-key = MmI5NjMxNGQtNjJkNS00NDc1LWI3NGMtZWYwMmM2ZDA3ZjQx
    And call Project.feature@GetProjectId
    And call Workspace.feature@GetWorkspaceId
    And endpoint /workspaces/{{workspaceId}}/projects/{{projectId}}
    And set value "1" of key id in body jsons/bodies/bodyUpdateProject.json
    When execute method PUT
    Then the status code should be 200
    And response should be archived = true


  @Projects @DeleteProject
  Scenario:  Delete Project recently created
    And header x-api-key = MmI5NjMxNGQtNjJkNS00NDc1LWI3NGMtZWYwMmM2ZDA3ZjQx
    And call Workspace.feature@GetWorkspaceId
    And call Project.feature@GetProjectId
    And endpoint /workspaces/{{workspaceId}}/projects/{{projectId}}
    When execute method DELETE
    Then the status code should be 200

  @Projects @AddProject
  Scenario: Add new project
    And header x-api-key = MmI5NjMxNGQtNjJkNS00NDc1LWI3NGMtZWYwMmM2ZDA3ZjQx
    And call Workspace.feature@GetWorkspaceId
    And call Project.feature@GetProjectName
    And endpoint /workspaces/{{workspaceId}}/projects
    And set value {{projectName}} of key name in body jsons/bodies/bodyCreateProject.json
    When execute method POST
    Then the status code should be 201
    And response should be name = {{projectName}}


  @Projects @AddProject @Failed
  Scenario Outline: Add new project without body
    And header x-api-key = MmI5NjMxNGQtNjJkNS00NDc1LWI3NGMtZWYwMmM2ZDA3ZjQx
    And call Workspace.feature@GetWorkspaceId
    And endpoint /workspaces/{{workspaceId}}/projects
    When execute method POST
    Then the status code should be 400
    And verify the response message 'contains' <message>
    Examples:
      | message     |
      | Required request body is missing |

  @Projects @GetProjects
  Scenario Outline: Get project by name
    And header x-api-key = MmI5NjMxNGQtNjJkNS00NDc1LWI3NGMtZWYwMmM2ZDA3ZjQx
    And call Workspace.feature@GetWorkspaceId
    And endpoint /workspaces/{{workspaceId}}/projects
    And add query parameter '<name>' = <name>
    And add query parameter '<strict-name-search>' = <strict-name-search>
    When execute method GET
    Then the status code should be 200
    And response should be [1].name = <name>
    Examples:
      | name                      | strict-name-search |
      | new project automation 02 | 1                  |


  @Projects @GetProjects
  Scenario Outline: Find project by ID valid
    And header x-api-key = MmI5NjMxNGQtNjJkNS00NDc1LWI3NGMtZWYwMmM2ZDA3ZjQx
    And call Workspace.feature@GetWorkspaceId
    And endpoint /workspaces/{{workspaceId}}/projects/671a5ca84800084f06377be6
    When execute method GET
    Then the status code should be 200
    And response should be name = <name>
    Examples:
      | name             |
      | Project test 222 |


  @Projects @GetProjects @Failed
  Scenario Outline: Get project by name with api token invalid
    And header x-api-key = ZWIwYTQ0ODMtMmY3OC00MmUyLTk3ZWYtY2QyNTU5YWY5Mjg4Fake
    And endpoint /workspaces/67182d64ab5dd152ad9aa1c6/projects
    And header name = <name>
    When execute method GET
    Then the status code should be 401
    And response should be message = <message>
    Examples:
      | message                |
      | Api key does not exist |

  @Projects @GetProjects @Failed
  Scenario Outline: Get project setting a invalid url
    And header x-api-key = MmI5NjMxNGQtNjJkNS00NDc1LWI3NGMtZWYwMmM2ZDA3ZjQx
    And endpoint /workspaces/67182d64ab5dd152ad9aa1c6/project/671823f39fb57324b218537999
    When execute method GET
    Then the status code should be 404
    And verify the response message 'contains' <message>
    Examples:
      | message            |
      | No static resource |

  @Projects @GetProjects @Failed
  Scenario Outline: Get project by id invalid
    And header x-api-key = MmI5NjMxNGQtNjJkNS00NDc1LWI3NGMtZWYwMmM2ZDA3ZjQx
    And endpoint /workspaces/67182d64ab5dd152ad9aa1c6/projects/671823f39fb57324b218537999FAKE
    When execute method GET
    Then the status code should be 400
    And verify the response message 'contains' <message>
    Examples:
      | message                             |
      | Project doesn't belong to Workspace |
