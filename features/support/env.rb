require 'cucumber'
require 'rspec'
require 'rails/generators/base'

AfterConfiguration do
  # Remove the old rails app used for testing if it exists, and create a new one.
  FileUtils.rm_rf "test/tmp"
  FileUtils.mkdir_p("test/tmp")
  system("rails new test/tmp/rails_app")
  if File.exist?('test/tmp/rails_app/Gemfile')
    ::Rails::Generators::Base.new.insert_into_file "test/tmp/rails_app/Gemfile", "gem 'regenerate', :path => '../../../'\n", :after => "gem 'sqlite3'\n"
  end
end

Before do
  @current_directory = File.expand_path("test/tmp/rails_app")
end