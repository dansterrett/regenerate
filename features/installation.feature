Feature: Regenerate Installation Generator
  In order to install Regenerate
  As a rails developer
  I want to install Regenerate
  
  Scenario: Installing Regenerate
    Given a new Rails app
    When I install regenerate
    Then I should see all the template files
    