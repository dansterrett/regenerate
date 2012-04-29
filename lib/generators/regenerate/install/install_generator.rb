require 'rails/generators/base'
require 'generators/regenerate'

module Regenerate
  module Generators
    class InstallGenerator < ::Regenerate::Generators::Base
      desc "This generator installs Regenerate templates to the app/scaffold directory"
      
      def add_templates
        #copy_file "../../../../../app/scaffold/bootstrap/show.html.erb", "app/scaffold/bootstrap/show.html.erb"
        copy_file "themes/bootstrap/_form.html.erb", "app/scaffold/bootstrap/_form.html.erb"
        copy_file "themes/bootstrap/edit.html.erb", "app/scaffold/bootstrap/edit.html.erb"
        copy_file "themes/bootstrap/index.html.erb", "app/scaffold/bootstrap/index.html.erb"
        copy_file "themes/bootstrap/new.html.erb", "app/scaffold/bootstrap/new.html.erb"
        copy_file "themes/bootstrap/show.html.erb", "app/scaffold/bootstrap/show.html.erb"
      end      
    end
  end
end
