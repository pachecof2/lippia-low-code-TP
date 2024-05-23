@Samplexml
Feature: Sample

  Background:
    And endpoint pet
    And header accept = application/xml
    And header Content-Type = application/xml

  @petstoreXML
  Scenario: Add a new pet to the store with xml format
    * define body = read(xmls/bodies/pets.xml)
    Given base url $(env.base_url_petstore)
    And set value "doggie2323" of key Pet.name in body $(var.body)
    And set value "13245" of key Pet.id in body $(var.body)
    And body $(var.body)
    When execute method POST
    Then the status code should be 200
    And response should be Pet.name = doggie2323
    And validate schema read(xmls/schemas/pets.xsd)


  @petstoreXML
  Scenario Outline: Add a new pet to the store with xml format outline
    * define body = read(xmls/bodies/pets.xml)
    Given base url $(env.base_url_petstore)
    And set value "doggies" of key Pet.name in body $(var.body)
    And set value "124" of key Pet.id in body $(var.body)
    And body $(var.body)
    When execute method POST
    Then the status code should be 200
    And response should be Pet.name = <name>

    Examples:
      | name    |
      | doggies |