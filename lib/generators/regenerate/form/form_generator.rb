require 'generators/regenerate'
require 'rails/generators/migration'
require 'rails/generators/generated_attribute'

module Regenerate
  module Generators
    class FormGenerator < Common
      
      def set_controller_actions
        @controller_actions = ["new", "create", "edit", "update"]
      end
      
      def create_the_controller
        unless @skip_controller
          create_controller
        end
      end
      
      def create_the_views
        create_views(["new", "edit", "_form"])
      end
      
    end
  end
end