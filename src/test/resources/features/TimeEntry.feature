@DatetimeEntry @TPFinal
Feature: Datetime Entry
  Background:
    Given base url https://api.clockify.me/api/v1
    And header Content-Type = application/json
    And header x-api-key = MmI5NjMxNGQtNjJkNS00NDc1LWI3NGMtZWYwMmM2ZDA3ZjQx

  @DatetimeEntry @GetTimeById
    Scenario Outline: Get time Entry for a Project by ID Successfully
      And call Workspace.feature@GetWorkspaceId
      And endpoint /workspaces/{{workspaceId}}/time-entries/6723c04473d2504d5ab54719
      When execute method GET
      Then the status code should be 200
      And response should be $.description = <description>
      And response should be $.timeInterval.start = <start>
      And response should be $.timeInterval.end = <end>
      And response should be $.timeInterval.duration = <duration>
      Examples:
        | description                 | start                | end                 | duration |
        | automatizacion agrega data. | 2024-10-31T09:00:00Z | 2024-10-31T18:00:00Z | PT9H     |


  @DatetimeEntry @GetTimeByUser
  Scenario: Get time Entry by User Successfully
    And call Workspace.feature@GetWorkspaceId
    And endpoint /workspaces/{{workspaceId}}/user/6621208b38907a5b7a6174c7/time-entries
    When execute method GET
    Then the status code should be 200
    And validate schema jsons/schemas/getTime.json
    Then response should be $[0].timeInterval.duration = PT3S


  @DatetimeEntry @AddNewTimeEntry
  Scenario: Add time Entry for a Project successfully
    And call Workspace.feature@GetWorkspaceId
    And endpoint /workspaces/{{workspaceId}}/time-entries
    And body read(jsons/bodies/bodyAddDataEntry.json)
    When execute method POST
    Then the status code should be 201
    And response should be $.description = Automatizacion carga de horas LTM
    And response should be $.timeInterval.start = 2025-12-31T09:00:00Z
    And response should be $.timeInterval.end = 2025-12-31T18:00:00Z
    And response should be $.timeInterval.duration = PT9H
    * define newTimeEntryId = response.id

  @DatetimeEntry @UpdateDatetime
  Scenario Outline: Update DateTime and description entry successfully
    And call Workspace.feature@GetWorkspaceId
    And call TimeEntry.feature@AddNewTimeEntry
    And endpoint /workspaces/{{workspaceId}}/time-entries/{{newTimeEntryId}}
    And body read(jsons/bodies/bodyUpdateDataEntry.json)
    When execute method PUT
    Then the status code should be 200
    And response should be $.description = <description>
    And response should be $.timeInterval.start = <start_new>
    And response should be $.timeInterval.end = <end_new>

    Examples:
      | description      | start_new            | end_new              |
      | New name updated | 2024-11-28T09:00:00Z | 2024-11-28T18:00:00Z |

  @DatetimeEntry @DeleteEntry
  Scenario: Delete data entry of a new Time Entry
    Given call TimeEntry.feature@UpdateDatetime
    And call Workspace.feature@GetWorkspaceId
    And endpoint /workspaces/{{workspaceId}}/time-entries/{{newTimeEntryId}}
    And execute method DELETE
    Then the status code should be 204

  @DatetimeEntry @AddTimeFailed
  Scenario Outline: Add time Entries failed for a Project by <description>
    * define body = read(jsons/bodies/bodyAddDataEntry.json)
    And call Workspace.feature@GetWorkspaceId
    And endpoint /workspaces/{{workspaceId}}/time-entries
    And set value <description> of key description in body $(var.body)
    And set value <start> of key start in body $(var.body)
    And set value <end> of key end in body $(var.body)
    And set value <projectId> of key projectId in body $(var.body)
    And set value ["6723a0b3f4e31810f4e9e0ca", "6723a0b3f4e31810f4e9e0ca"] of key tagIds in body $(var.body)
    When execute method POST
    Then the status code should be <statusCode>
    And verify the response message 'contains' <message>
    Examples:
      | statusCode | description                   | start                | end                  | projectId                | message                                                                                |
      | 400        | Date invalid                  | 2024-10-31T22:00:00Z | 2024-10-31T16:00:00Z | 672388f2cd910a7793f36111 | Start datetime 2024-10-31T22:00:00Z is greater than end datetime 2024-10-31T16:00:00Z. |
      | 400        | Id project invalid            | 2024-10-31T09:00:00Z | 2024-10-31T18:30:00Z | 672388f2cd910a7793f36114 | Project doesn't belong to Workspace                                                    |
      | 400        | Date start empty              |                      | 2024-10-31T18:40:00Z | 672388f2cd910a7793f36111 | You entered invalid value for field : [start]                                          |
      | 400        | Date end empty                | 2024-10-31T09:00:00Z |                      | 672388f2cd910a7793f36111 | You entered invalid value for field : [end]                                            |
      | 400        | Datetime greater an 999 hours | 2024-10-31T09:00:00Z | 2029-10-31T09:00:00Z | 671a5946c9a7b24e6bcf0fd3 | Time entry cannot have duration more than 999 hours.                                   |

  @DatetimeEntry @GetTimeFailed
  Scenario Outline: Get time Entry Failed by <motive>
    And endpoint <endpoint>
    When execute method GET
    Then the status code should be <statusCode>
    And verify the response message 'contains' <motive>

    Examples:
      | motive                           | endpoint                                                                                | statusCode |
      | User doesn't belong to Workspace | /workspaces/67182d64ab5dd152ad9aa1c6/user/6621208b38907a5b7a6174c8/time-entries         | 400        |
      | No static resource               | /workspaces/67182d64ab5dd152ad9aa1c6/user-entries/6621208b38907a5b7a6174c4/time-entries | 404        |
      | Access Denied                    | /workspaces/67182d64ab5dd152ad9aa1c8/user/6621208b38907a5b7a6174c9/time-entries         | 403        |

  @DatetimeEntry @UpdateDatetimeFailed
  Scenario Outline: Update DateTime entry Failed by <description>
    And call TimeEntry.feature@AddNewTimeEntry
    * define body = read(jsons/bodies/bodyAddDataEntry.json)
    And endpoint /workspaces/67182d64ab5dd152ad9aa1c6/time-entries/{{newTimeEntryId}}
    And set value <startDate> of key start in body $(var.body)
    And set value <endDate> of key end in body $(var.body)
    And set value <projectId> of key projectId in body $(var.body)
    And set value <description> of key start in body $(var.body)
    When execute method PUT
    Then the status code should be <statusCode>
    Examples:
      | statusCode | description                   | startDate            | endDate              | projectId                |
      | 400        | Date invalid                  | 2024-10-31T22:00:00Z | 2024-10-31T16:00:00Z | 672388f2cd910a7793f36111 |
      | 400        | Id project invalid            | 2024-10-31T09:00:00Z | 2024-10-31T18:30:00Z | 672388f2cd910a7793f36114 |
      | 400        | Date start empty              |                      | 2024-10-31T18:40:00Z | 672388f2cd910a7793f36111 |
      | 400        | Date end empty                | 2024-10-31T09:00:00Z |                      | 672388f2cd910a7793f36111 |
      | 400        | Datetime greater an 999 hours | 2024-10-31T09:00:00Z | 2029-10-31T09:00:00Z | 672388f2cd910a7793f36111 |
