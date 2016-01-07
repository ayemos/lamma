require "simplecov"
SimpleCov.start

lp = File.expand_path('../../lib', __FILE__)
p lp
Dir.glob(File.join(lp, '**/*.rb')).each{|l| require l} # for simplecov

$LOAD_PATH.unshift lp # for in-place test

require 'pathname'

module SpecHelper
  def fixture_root
    Pathname.new(__FILE__).dirname.join('fixtures')
  end
end
