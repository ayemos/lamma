require 'yaml'

require 'lamma'
require 'lamma/function'
require 'lamma/alias'

module Lamma
  class CLI::Deploy
    attr_reader :options, :thor

    def initialize(options, thor)
      @options = options
      @thor = thor
      @conf_path = options['path'] || Lamma::DEFAULT_CONF_PATH
    end

    def run
      unless File.exists?(@conf_path)
        abort("Config file #{@conf_path} is missing.")
      end

      f = Lamma::Function.new(@conf_path)

      unless f.remote_exists?
        thor.say("Function #{function.name} doesn't seem to be exist on remote.", :yellow)
        y_or_n = thor.ask("Do you want me to create it? (y/n)", :yellow)

        if y_or_n =~ /^[yY]/
          f.create
        end
      end

      f.update
      new_version = f.publish_version(options['message']).version

      if options['alias']
        a = Lamma::Alias.new(f, options['alias'], new_version)

        if a.remote_exists? && a.remote_version
          last_version = a.remote_version
          a.update
        else
          last_version = new_version

          thor.say("Function alias #{a.name} doesn't seem to be exist on remote.", :yellow)
          y_or_n = thor.ask("Do you want me to create it? (y/n)", :yellow)

          if y_or_n =~ /^[yY]/
            a.create
          else
            abort('Canceled')
          end
        end

        la = Lamma::Alias.new(f, "#{@options['alias']}_#{Lamma::LAST_DEPLOY_SUFFIX}", last_version)
        la.create_or_update
      end
    end

    private

    def create_function(function, config)
      begin
        function.create_function(config['runtime'], config['role'])
      rescue ArgumentError
        thor.say("ArgumentError occured. You might need to specify role arn \
you want to pass to your function via 'lamma.conf' file or ENV['AWS_LAMBDA_IAM_ROLE'].", :red)
        return
      end
      thor.say("Done.", :blue)
      thor.say("Setting aliases.", :yellow)
      first_version = function.publish_version.version
      Lamma::Function::ENVIRONMENT_ALIAS_NAME_MAP.values.each do |alias_name|
        function.create_alias(alias_name, first_version)
        function.create_alias(alias_name << '_LAST', first_version)
      end
    end
  end
end
