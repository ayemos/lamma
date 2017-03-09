require 'yaml'

require 'lamma'
require 'lamma/function'
require 'lamma/alias'
require 'lamma/shared_helpers'

module Lamma
  class CLI::Deploy
    include SharedHelpers

    attr_reader :options, :thor

    def initialize(options, thor)
      @options = options
      @thor = thor
      @conf_path = search_conf_path(options['path'] || Lamma::DEFAULT_CONF_PATH)
    end

    def run
      unless File.exist?(@conf_path)
        abort("Config file #{@conf_path} is missing.")
      end

      f = Lamma::Function.new(@conf_path)
      update_or_create_function(f)

      new_version = f.publish_version(options['message']).version

      if options['alias']
        update_or_create_alias(f, new_version)
      end
    end

    private

    def update_or_create_alias(f, new_version)
      a = Lamma::Alias.new(f, options['alias'], new_version)

      if a.remote_exist? && a.remote_version
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

    def update_or_create_function(f)
      if f.remote_exist?
        f.update
      else
        thor.say("Function #{f.name} doesn't seem to be exist on remote.", :yellow)
        y_or_n = thor.ask("Do you want me to create it? (y/n)", :yellow)

        if y_or_n =~ /^[yY]/
          f.create
        end
      end
    end
  end
end
