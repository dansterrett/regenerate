require 'generators/regenerate'
require 'rails/generators/migration'
require 'rails/generators/generated_attribute'

module Regenerate
  module Generators
    class ListingGenerator < Common
      
      def set_controller_actions
        @controller_actions = ["index"]
      end
      
      def create_the_controller
        unless @skip_controller
          create_controller
        end
      end
      
      def create_the_views
        create_views(["index"])
      end
      
    end
  end
end