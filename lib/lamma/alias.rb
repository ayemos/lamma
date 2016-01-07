module Lamma
  class Alias
    attr_accessor :description, :version

    def initialize(function, name, version=nil, description=nil)
      @function = function
      @name = name
      @version = version
      @description = description
    end

    def create
      lambda_client.create_alias({
        function_name: @function.name,
        name: name, # 'name' indicates the self
        function_version: @version,
        description: description
      })
    end

    def update
      lambda_client.update_alias({
        function_name: @function.name,
        name: name, # 'name' indicates the self
        function_version: @version,
        description: description
      })
    end

    def create_or_update
      if remote_exists?
        update
      else
        create
      end
    end

    def name
      @name.upcase
    end

    def remote_exists?
      begin
        lambda_client.get_alias({
          function_name: @function.name,
          name: name
        })
      rescue Aws::Lambda::Errors::ResourceNotFoundException
        false
      end
    end

    def remote_version
      begin
        lambda_client.get_alias({
          function_name: @function.name,
          name: name
        }).function_version
      rescue Aws::Lambda::Errors::ResourceNotFoundException
        nil
      end
    end

    private

    def description
      @description ||= "Function alias #{name} managed by lamma"
    end

    def lambda_client
      @lambda_client ||= Aws::Lambda::Client.new(region: @function.region)
    end
  end
end
