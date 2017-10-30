module Lamma
  class CLI::Show
    def initialize(options, function_name, thor)
      @options = options
      @thor = thor
      @function_name = function_name
      @conf_path = options[:conf_path] || Lamma::DEFAULT_CONF_PATH
    end

    def run
      f = Lamma::Function.new(@function_name)

      unless f.remote_exist?
        thor.say("Function #{f.name} doesn't exist in remote.")
      end

      thor.say(f) # XXX:
    end
  end
end
