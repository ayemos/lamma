require 'lamma/cli'

module Lamma
  class CLI::Create
    def initialize(options, thor)
      @options = options
      @thor = thor
      @conf_path = options[:path] || Lamma::DEFAULT_CONF_PATH
    end

    def run
      f = Lamma::Function.new(@conf_path)
      f.create
    end
  end
end
