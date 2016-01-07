module Lamma
  class DeadLetterConfig
    def initialize(yaml)
      @target_arn = yaml.fetch('target_arn', nil)
    end
  end
end
