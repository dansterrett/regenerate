require 'generators/regenerate'
require 'rails/generators/migration'
require 'rails/generators/generated_attribute'

module Regenerate
  module Generators
    class ScaffoldGenerator < Common
      
      def create_the_controller
        unless @skip_controller
          create_controller
        end
      end
      
      def create_the_views
        create_views
      end
      
    end
  end
end
