require 'lamma'
require 'thor'

module Lamma
  class CLI < Thor
    class_option :verbose, aliases: '-v', type: :boolean
    class_option :profile, aliases: '-p', type: :string
    map '--version' => :print_version

    desc 'list', 'List lambda functions in AWS'
    def list
      require 'lamma/cli/list'
      List.new(options, self).run
    end

    desc 'show FUNCTION_NAME', 'Show detailed description of the function'
    def show(function_name)
      require 'lamma/cli/show'
      Show.new(options, self).run
    end

    desc 'deploy', 'Upload local lambda function to AWS and deploy.'
    method_option :path, aliases: '-p', type: :string
    method_option :alias, aliases: '-a', type: :string
    method_option :message, aliases: '-m', type: :string
    def deploy
      require 'lamma/cli/deploy'
      Deploy.new(options, self).run
    end

    desc 'rollback', 'Rollback last deploy.'
    method_option :path, aliases: '-p', type: :string
    method_option :alias, aliases: '-a', type: :string
    def rollback
      require 'lamma/cli/rollback'
      Rollback.new(options, self).run
    end

    desc 'create', 'Create new remote function.'
    method_option :path, aliases: '-p', type: :string
    def create
      require 'lamma/cli/create'
      Create.new(options, self).run
    end

    desc 'init FUNCTION_NAME', 'Initialize local function'
    method_option :runtime, aliases: '-r', type: :string, required: true
    method_option :role_arn, aliases: %w(--role-arn -R), type: :string
    def init(function_name)
      require 'lamma/cli/init'
      Init.new(options, function_name, self).run
    end

    desc "update", "Update function configuration and upload function"
    def update
      require 'lamma/cli/update'
      Update.new(options, self).run
    end

    desc "--version", "print the version"
    def print_version
      puts Lamma::VERSION
    end
  end
end
