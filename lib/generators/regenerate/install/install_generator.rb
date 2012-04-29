require 'rails/generators/base'
require 'generators/regenerate'

module Regenerate
  module Generators
    class InstallGenerator < ::Regenerate::Generators::Base
      desc "This generator installs Regenerate templates to the app/scaffold directory"
      
      def add_templates
        view_templates_path = File.expand_path(File.join(File.dirname(__FILE__), '../../../../app/scaffold'))
        copy_file view_templates_path + "/bootstrap/_form.html.erb", "app/scaffold/bootstrap/_form.html.erb"
        copy_file view_templates_path + "/bootstrap/edit.html.erb", "app/scaffold/bootstrap/edit.html.erb"
        copy_file view_templates_path + "/bootstrap/index.html.erb", "app/scaffold/bootstrap/index.html.erb"
        copy_file view_templates_path + "/bootstrap/new.html.erb", "app/scaffold/bootstrap/new.html.erb"
        copy_file view_templates_path + "/bootstrap/show.html.erb", "app/scaffold/bootstrap/show.html.erb"
        copy_file view_templates_path + "/bootstrap/viewSettings.yaml", "app/scaffold/bootstrap/viewSettings.yaml"
      end
    end
  end
end
