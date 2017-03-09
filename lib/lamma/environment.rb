module Lamma
  class Environment
    attr_accessor :variables

    def initialize(yaml)
      @variables = yaml.fetch('variables', {})
    end

    def to_h
      {
        variables: @variables
      }
    end
  end
end
