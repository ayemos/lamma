require 'yaml'

require 'lamma'
require 'lamma/function'
require 'lamma/alias'
require 'lamma/shared_helpers'

module Lamma
  class CLI::Rollback
    include SharedHelpers

    attr_reader :options, :thor, :path

    def initialize(options, thor)
      @options = options
      @thor = thor
      @conf_path = search_conf_path(options['path'] || Lamma::DEFAULT_CONF_PATH)
    end

    def run
      unless File.exists?(@conf_path)
        abort("Config file #{@conf_path} is missing.")
      end

      f = Lamma::Function.new(@conf_path)

      unless f.remote_exists?
        abort("Remote function #{f.name} doesn't seem to be exists. You have to create or deploy it first")
      end

      unless options['alias']
        abort("You can't rollback with alias (-a) option.")
      end

      a = Lamma::Alias.new(f, options['alias'])

      unless a.remote_exists?
        abort("Alias #{a.name} doesn't exist. You have to deploy the function first.")
      end

      la = Lamma::Alias.new(f, "#{options['alias']}_#{Lamma::LAST_DEPLOY_SUFFIX}")

      unless la.remote_exists?
        abort("Alias #{la.name} doesn't exist. You have to deploy the function first.")
      end

      v = a.remote_version
      lv = la.remote_version

      if v == lv
        abort("Aliases #{a.name} and #{la.name} indicates same version #{v}. Deploy it first?")
      end

      a.version = lv

      Lamma.logger.info("Updating alias configuration")
      a.update
    end

    private
    def templates_path
      File.expand_path(File.join(File.dirname(__FILE__), '../templates'))
    end
  end
end
