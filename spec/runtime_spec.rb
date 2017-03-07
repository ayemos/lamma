require 'spec_helper'

RSpec.describe Lamma::Runtime do
  context 'python' do
    let(:runtime) { described_class.new('python') }

    it 'describe runtime with normalized name' do
      expect(runtime.to_s).to eq('python2.7')
    end

    it 'escape dots and dash to underscore with dirname' do
      expect(runtime.to_dirname).to eq('python2_7')
    end
  end

  context 'c#' do
    let(:runtime) { described_class.new('c#') }

    it 'describe runtime with normalized name' do
      expect(runtime.to_s).to eq('dotnetcore1.0')
    end

    it 'escape dots and dash to underscore with dirname' do
      expect(runtime.to_dirname).to eq('dotnetcore1_0')
    end
  end

  context 'node43' do
    let(:runtime) { described_class.new('node') }

    it 'describe runtime with normalized name' do
      expect(runtime.to_s).to eq('nodejs4.3')
    end

    it 'escape dots and dash to underscore with dirname' do
      expect(runtime.to_dirname).to eq('nodejs4_3')
    end
  end

  context 'edgenode' do
    let(:runtime) { described_class.new('edgenode') }

    it 'describe runtime with normalized name' do
      expect(runtime.to_s).to eq('nodejs4.3-edge')
    end

    it 'escape dots and dash to underscore with dirname' do
      expect(runtime.to_dirname).to eq('nodejs4_3_edge')
    end
  end

  context 'java8' do
    let(:runtime) { described_class.new('java') }

    it 'describe runtime with normalized name' do
      expect(runtime.to_s).to eq('java8')
    end

    it 'escape dots and dash to underscore with dirname' do
      expect(runtime.to_dirname).to eq('java8')
    end
  end
end
