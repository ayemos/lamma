module Lamma
  class Runtime
    attr_reader :type

    def self.all
      self.constants.map{|n| [n, self.const_get(n)] }.to_h
    end

    C_SHARP = 10
    JAVA_8 = 20
    NODE_43 = 30
    EDGE_NODE_43 = 31
    PYTHON_27 = 40

    def initialize(str)
      @type = case str
      when /^c[s#](harp)?$/i
        ::Lamma::Runtime::C_SHARP
      when /^java([-_\.\s]*8?)?$/i
        ::Lamma::Runtime::JAVA_8
      when /^node([-_\.\s]*4(\.?3)?)?$/i
        ::Lamma::Runtime::NODE_43
      when /^edge[-_\.\s]*node(\s*4(\.?3)?)?$/i
        ::Lamma::Runtime::EDGE_NODE_43
      when /^python([-_\.\s]*2(\.?7)?)?$/i
        ::Lamma::Runtime::PYTHON_27
      else
        raise ArgumentError.new("invalid runtime. #{str}")
      end
    end

    NAME = {
      C_SHARP => 'dotnetcore1.0',
      JAVA_8 => 'java8',
      NODE_43 => 'nodejs4.3',
      EDGE_NODE_43 => 'nodejs4.3-edge',
      PYTHON_27 => 'python2.7'
    }

    def to_s
      NAME[@type]
    end

    def to_dirname
      NAME[@type].gsub(/[\.-]/, '_')
    end
  end
end
