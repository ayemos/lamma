module Lamma
  class VpcConfig
    def initialize(yaml)
      @subnet_ids = yaml.fetch('subnet_ids', nil)
      @security_group_ids = yaml.fetch('security_group_ids', nil)
    end

    def to_h
      {
        subnet_ids: @subnet_ids,
        security_group_ids: @security_group_ids
      }
    end
  end
end
