require 'rails/generators/base'

module Regenerate
  module Generators
    class Base < ::Rails::Generators::Base
      def self.source_root
        @source = File.expand_path(File.join(File.dirname(__FILE__), '../../app/scaffold'))
      end      
    end
  
    class Common < Base
      include ::Rails::Generators::Migration
      no_tasks { attr_accessor :scaffold_name, :model_attributes, :controller_actions }
      
      argument :scaffold_name, :type => :string, :required => true, :banner => 'ScaffoldName'
      argument :args_for_c_m, :type => :array, :default => [], :banner => 'controller_actions and model:attributes'
      
      class_option :skip_model, :desc => 'Don\'t generate a model or migration file.', :type => :boolean
      class_option :skip_migration, :desc => 'Don\'t generate migration file for model.', :type => :boolean
      class_option :skip_timestamps, :desc => 'Don\'t add timestamps to migration file.', :type => :boolean
      class_option :skip_controller, :desc => 'Don\'t generate controller, helper, or views.', :type => :boolean
      class_option :invert, :desc => 'Generate all controller actions except these mentioned.', :type => :boolean
      class_option :handlebars, :desc => 'Generate Handlebars views instead of ERB.', :type => :boolean
      class_option :namespace_model, :desc => 'If the resource is namespaced, include the model in the namespace.', :type => :boolean
      
      def initialize(*args, &block)
        super
        
        @controller_actions = []
        @model_attributes = []
        @isJS_template_language = options.handlebars?
        @skip_model = options.skip_model? || @isJS_template_language
        @skip_migration = options.skip_migration? || @skip_model
        @namespace_model = options.namespace_model?
        @invert_actions = options.invert?
        @template_language = (options.handlebars ? "handlebars" : "erb")
        @skip_controller = options.skip_controller? || @isJS_template_language
        @template_file_ext = (options.handlebars ? "html" : "html.erb")
        @theme = "bootstrap"
        @view_settings = YAML::load(File.open(Base.source_root + '/views/' + @theme + '/viewSettings.yaml'))
        
        args_for_c_m.each do |arg|
          if arg == '!'
            @invert_actions = true
          elsif arg.include?(':')
            @model_attributes << ::Rails::Generators::GeneratedAttribute.new(*arg.split(':'))
          else
            @controller_actions << arg
            @controller_actions << 'create' if arg == 'new'
            @controller_actions << 'update' if arg == 'edit'
          end
        end
                
        if @invert_actions || @controller_actions.empty?
          @controller_actions = all_actions - @controller_actions
        end

        @controller_actions.uniq!
        @model_attributes.uniq!

        if @model_attributes.empty?
          @skip_model = true # skip model if no attributes
          if model_exists?
            model_columns_for_attributes.each do |column|
              @model_attributes << ::Rails::Generators::GeneratedAttribute.new(column.name.to_s, column.type.to_s)
            end
          end
        end
      end
      
      def create_model
        unless @skip_model
          template 'model.rb', "app/models/#{model_path}.rb"
          if test_framework == :rspec
            template "tests/rspec/model.rb", "spec/models/#{model_path}_spec.rb"
            template 'fixtures.yml', "spec/fixtures/#{model_path.pluralize}.yml"
          else
            template "tests/#{test_framework}/model.rb", "test/unit/#{model_path}_test.rb"
            template 'fixtures.yml', "test/fixtures/#{model_path.pluralize}.yml"
          end
        end
      end

      def create_migration
        unless @skip_migration || @skip_model
          migration_template "migration.rb", "db/migrate/create_#{model_path.pluralize.gsub('/', '_')}.rb"
        end
      end
      
      private
      
      def create_controller
        unless @skip_controller
          
          template 'controller.rb', "app/controllers/#{plural_name}_controller.rb"

          template 'helper.rb', "app/helpers/#{plural_name}_helper.rb"

          if test_framework == :rspec
            template "tests/#{test_framework}/controller.rb", "spec/controllers/#{plural_name}_controller_spec.rb"
          else
            template "tests/#{test_framework}/controller.rb", "test/functional/#{plural_name}_controller_test.rb"
          end
          
          namespaces = plural_name.split('/')
          resource = namespaces.pop
          route namespaces.reverse.inject("resources :#{resource}") { |acc, namespace|
            "namespace(:#{namespace}){ #{acc} }"
          }
        end
      end
      
      def create_views(views = nil)
        if (views == nil)
          views = []
          @controller_actions.each do |action|
            if (%w[new edit index show].include?(action))
              views.push(action)
            end
          end
          
          if (views.include?("new") || views.include?("edit"))
            views.push("_form");
          end
        end
        
        viewsToCreate = []
        
        views.each do |view|
          viewsToCreate.push(view) unless (%w[new edit].include?(view) && @isJS_template_language)
        end
        
        viewsToCreate.each do |view|
          if %w[new edit index show _form].include?(view)
            template "views/" + @theme + "/" + view + ".html.erb", "app/views/#{plural_name}/" + view + "." + @template_file_ext
          end
        end
      end
      
      # erb methods
      # the setting name should be something like "form_start"
      # params should be a string or an array of strings
      def get_view_setting(setting_name, params = nil)
        view_settings_for_template_language = @view_settings[@template_language.to_sym]
        stringVal = eval("view_settings_for_template_language[:" + setting_name + "]")
        if (params)
          return stringVal % params
        else
          return stringVal
        end
      end
      
      def get_form_field_label(attribute_name)
        case @template_language
        when "erb"
          get_view_setting("form_label", attribute_name)
        when "handlebars"
          get_view_setting("form_label",  [singular_name + '_' + attribute_name, ActiveRecord::Base.human_attribute_name(attribute_name)])
        end
      end
      
      def get_form_field(attribute_name, attribute_field_type)
        case @template_language
        when "erb"
          get_view_setting("form_field", [attribute_field_type, attribute_name, attribute_field_type])
        when "handlebars"
          get_view_setting("form_" + attribute_field_type.to_s, [ singular_name + '_' + attribute_name.to_s, singular_name + '[' + attribute_field_type.to_s + ']' ] )
        end
      end
      
      def get_show_start
        case @template_language
        when "erb"
          return ""
        when "handlebars"
          get_view_setting("show_start", singular_name)
        end
      end
      
      def get_show_end
        case @template_language
        when "erb"
          return ""
        when "handlebars"
          get_view_setting("show_end")
        end
      end
      
      def get_index_start
        case @template_language
        when "erb"
          return ""
        when "handlebars"
          get_view_setting("index_start", singular_name)
        end
      end
      
      def get_index_end
        case @template_language
        when "erb"
          return ""
        when "handlebars"
          get_view_setting("index_end")
        end
      end
      
      def get_attribute_value(attribute_name, view)
        case @template_language
        when "erb"
          get_view_setting("attribute_value", [view == "show" ? "@" : "", instance_name, attribute_name])
        when "handlebars"
          get_view_setting("attribute_value", attribute_name)
        end
      end
      
      def get_new_link
        case @template_language
        when "erb"
          get_view_setting("new_link", [singular_name.titleize, item_path(:action => :new)])
        when "handlebars"
          get_view_setting("new_link", [plural_name, singular_name.titleize])
        end
      end
      
      def get_show_link
        case @template_language
        when "erb"
          get_view_setting("show_link", item_path)
        when "handlebars"
          get_view_setting("show_link", plural_name)
        end
      end
      
      def get_edit_link(view = "index")
        case @template_language
        when "erb"
          get_view_setting("edit_link_for_" + view + "_view" , item_path(:action => :edit, :instance_variable => (view == "show")))
        when "handlebars"
          get_view_setting("edit_link_for_" + view + "_view", plural_name)
        end
      end
      
      def get_delete_link(view = "index")
        case @template_language
        when "erb"
          get_view_setting("delete_link_for_" + view + "_view", item_path(:instance_variable => (view == "show")))
        when "handlebars"
          get_view_setting("delete_link_for_" + view + "_view", plural_name)
        end
      end
      
      def get_view_listing_link
        case @template_language
        when "erb"
          get_view_setting("view_listing_link", items_path)
        when "handlebars"
          get_view_setting("view_listing_link", plural_name)
        end
      end
      
      def get_form_cancel_link
        case @template_language
        when "erb"
          get_view_setting("form_cancel_link", items_path)
        when "handlebars"
          get_view_setting("form_cancel_link")
        end
      end
      
      def get_models_loop_start
        case @template_language
        when "erb"
          get_view_setting("models_loop_start", [instances_name, instance_name])
        when "handlebars"
          get_view_setting("models_loop_start", plural_name)
        end
      end
      
      def all_actions
        %w[index show new create edit update destroy]
      end
      
      def action?(name)
        @controller_actions.include? name.to_s
      end

      def actions?(*names)
        names.all? { |name| action? name }
      end
      
      def singular_name
        scaffold_name.underscore
      end
      
      def plural_name
        scaffold_name.underscore.pluralize
      end
      
      def table_name
        if scaffold_name.include?('::') && @namespace_model
          plural_name.gsub('/', '_')
        end
      end

      def class_name
        if @namespace_model
          scaffold_name.camelize
        else
          scaffold_name.split('::').last.camelize
        end
      end

      def model_path
        class_name.underscore
      end

      def plural_class_name
        plural_name.camelize
      end

      def instance_name
        if @namespace_model
          singular_name.gsub('/','_')
        else
          singular_name.split('/').last
        end
      end

      def instances_name
        instance_name.pluralize
      end

      def controller_methods(dir_name)
        @controller_actions.map do |action|
          read_template("#{dir_name}/#{action}.rb")
        end.join("\n").strip
      end

      def render_form
        if form_partial?
          if options.haml?
            "= render \"form\""
          else
            "<%= render \"form\" %>"
          end
        else
          read_template("views/#{view_language}/_form.html.#{view_language}")
        end
      end

      def item_resource
        scaffold_name.underscore.gsub('/','_')
      end

      def items_path
        if action? :index
          "#{item_resource.pluralize}_path"
        else
          "root_path"
        end
      end

      def item_path(options = {})
        name = options[:instance_variable] ? "@#{instance_name}" : instance_name
        suffix = options[:full_url] ? "url" : "path"
        if options[:action].to_s == "new"
          "new_#{item_resource}_#{suffix}"
        elsif options[:action].to_s == "edit"
          "edit_#{item_resource}_#{suffix}(#{name})"
        else
          if scaffold_name.include?('::') && !@namespace_model
            namespace = singular_name.split('/')[0..-2]
            "[:#{namespace.join(', :')}, #{name}]"
          else
            name
          end
        end
      end

      def item_url
        if action? :show
          item_path(:full_url => true, :instance_variable => true)
        else
          items_url
        end
      end

      def items_url
        if action? :index
          item_resource.pluralize + '_url'
        else
          "root_url"
        end
      end

      def item_path_for_spec(suffix = 'path')
        if action? :show
          "#{item_resource}_#{suffix}(assigns[:#{instance_name}])"
        else
          if suffix == 'path'
            items_path
          else
            items_url
          end
        end
      end

      def item_path_for_test(suffix = 'path')
        if action? :show
          "#{item_resource}_#{suffix}(assigns(:#{instance_name}))"
        else
          if suffix == 'path'
            items_path
          else
            items_url
          end
        end
      end

      def model_columns_for_attributes
        class_name.constantize.columns.reject do |column|
          column.name.to_s =~ /^(id|created_at|updated_at)$/
        end
      end

      def view_language
        options.haml? ? 'haml' : 'erb'
      end

      def test_framework
        return @test_framework if defined?(@test_framework)
        if options.testunit?
          return @test_framework = :testunit
        elsif options.rspec?
          return @test_framework = :rspec
        else
          return @test_framework = default_test_framework
        end
      end

      def default_test_framework
        File.exist?(destination_path("spec")) ? :rspec : :testunit
      end

      def model_exists?
        File.exist? destination_path("app/models/#{singular_name}.rb")
      end

      def read_template(relative_path)
        ERB.new(File.read(find_in_source_paths(relative_path)), nil, '-').result(binding)
      end

      def destination_path(path)
        File.join(destination_root, path)
      end

      # FIXME: Should be proxied to ActiveRecord::Generators::Base
      # Implement the required interface for Rails::Generators::Migration.
      def self.next_migration_number(dirname) #:nodoc:
        if ActiveRecord::Base.timestamped_migrations
          Time.now.utc.strftime("%Y%m%d%H%M%S")
        else
          "%.3d" % (current_migration_number(dirname) + 1)
        end
      end
      
    end
  end
end