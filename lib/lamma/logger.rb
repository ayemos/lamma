require 'logger'

module Lamma
  module Logger
  end

  @logger = ::Logger.new($stdout)

  class << self
    def logger
      @logger
    end
  end
end
