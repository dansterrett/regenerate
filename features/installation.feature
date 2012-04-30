Feature: Regenerate Installation Generator
  In order to install Regenerate
  As a rails developer
  I want to install Regenerate
  
  Scenario: Installing Regenerate
    Given an existing rails app
    When I run "rails g regenerate:install"
    Then I should see the following files
      | app/scaffold/bootstrap/_form.html.erb    |
      | app/scaffold/bootstrap/edit.html.erb     |
      | app/scaffold/bootstrap/index.html.erb    |
      | app/scaffold/bootstrap/new.html.erb      |
      | app/scaffold/bootstrap/show.html.erb     |
      | app/scaffold/bootstrap/viewSettings.yaml |
    