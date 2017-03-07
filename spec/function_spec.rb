require 'spec_helper'

require 'lamma'
require 'lamma/function'
require 'lamma/error'

RSpec.describe Lamma::Function do
  let(:fixture_name) { 'default.yml' }
  let(:function) { described_class.new(fixture_root.join('yaml', fixture_name)) }

  context 'simple' do

  end

  context 'without region' do
    let(:fixture_name) { 'without_region.yml' }

    it 'raise if region is not set' do
      expect { function.new(fixture_root.join('yaml', fixture_name)) }
        .to raise_error(Lamma::ValidationError)
    end
  end
end
