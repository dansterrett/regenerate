Feature: Regenerate Scaffold Generator
  In order to create a Regenerate scaffold
  As a rails developer
  I want to create a Regenerate scaffold
  
  Scenario: Scaffolding with Regenerate
    Given an existing rails app
    When I run "rails g regenerate:scaffold Product name:string description:text"
    Then I should see the following files
      | app/models/product.rb                         |
      | test/unit/product_test.rb                     |
      | test/fixtures/products.yml                    |
      | app/controllers/products_controller.rb        |
      | app/helpers/products_helper.rb                |
      | test/functional/products_controller_test.rb   |
      | app/views/products/_form.html.erb             |
      | app/views/products/edit.html.erb              |
      | app/views/products/index.html.erb             |
      | app/views/products/new.html.erb               |
      | app/views/products/show.html.erb              |
    And I should see "resources :products" in file "config/routes.rb"