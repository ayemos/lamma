require 'aws-sdk'
require 'pathname'
require 'yaml'

require 'lamma'
require 'lamma/runtime'
require 'lamma/code'
require 'lamma/vpc_config'
require 'lamma/dead_letter_config'
require 'lamma/environment'
require 'lamma/error'

module Lamma
  class Function
    # @!attribute [r] name
    #   @return [String]
    # @!attribute [r] region
    #   @return [String]
    # @!attribute [r] conf
    #   @return [Hash]
    # @!attribute [rw] publish
    #   @return [Bool]
    attr_reader :name, :region, :conf
    attr_accessor :publish

    # @param [String] yaml_path
    def initialize(yaml_path)
      path = Pathname.new(yaml_path)
      yaml = YAML.load(path.open)

      @conf = yaml.fetch('function', {})

      @publish = false
      @name = @conf.fetch('name', nil)
      @role_arn = @conf.fetch('role_arn', nil)
      @description = @conf.fetch('description', nil)
      @timeout = @conf.fetch('timeout', 3)
      @memory_size = @conf.fetch('memory_size', 128)
      # @dead_letter_config = dead_letter_config(@conf)
      @region = @conf.fetch('region') { raise Lamma::ValidationError.new('region must be set.') }
      @kms_key_arn = @conf.fetch('kms_key_arn', nil)
    end

    # @return [Lamma::Code]
    def code
      @code ||= Code.new(self, @conf.fetch('code', {}))
    end

    def create
      Lamma.logger.info("Creating new function #{@name}...")

      resp = lambda_client.create_function({
        function_name: @name,
        runtime: runtime.to_s,
        role: @role_arn,
        handler: handler,
        code: code.to_h,
        description: @description,
        timeout: @timeout,
        memory_size: @memory_size,
        publish: publish,
        vpc_config: vpc_config.to_h,
        environment: environment.to_h,
        kms_key_arn: @kms_key_arn
      })

      Lamma.logger.info("Created new function #{resp.function_arn}")
    end

    def update
      Lamma.logger.info('Updating function configuration...')

      resp = lambda_client.update_function_configuration({
        function_name: @name,
        runtime: runtime.to_s,
        role: @role_arn,
        handler: handler,
        description: @description,
        timeout: @timeout,
        memory_size: @memory_size,
        vpc_config: vpc_config.to_h,
        environment: environment.to_h,
        kms_key_arn: @kms_key_arn
      })

      Lamma.logger.info("Updated configuration for function: #{resp.function_arn}")

      Lamma.logger.info('Updating function code...')

      resp = lambda_client.update_function_code({
        function_name: @name,
        zip_file: code.to_h[:zip_file],
        publish: publish
      })

      Lamma.logger.info("Updated code for function: #{resp.function_arn}")
    end

    def update_or_create
      if remote_exist?
        update
      else
        create
      end
    end

    def aliases
      lambda_client.list_aliases({
        function_name: @name
      }).aliases.map do |a|
        Lamma::Alias.new(self, a.name, a.description)
      end
    end

    def versions
      lambda_client.list_versions_by_function({
        function_name: @name
      }).versions
    end

    def publish_version(v_desc, validate=nil)
      Lamma.logger.info("Publishing...")
      resp = lambda_client.publish_version({
        function_name: @name,
        code_sha_256: validate,
        description: v_desc
      })
      Lamma.logger.info("Published $LATEST version as version #{resp.version} of funtion: #{resp.function_arn}")
      resp
    end

    def remote_exist?
      begin
        lambda_client.get_function_configuration({
          function_name: @name,
        })
      rescue Aws::Lambda::Errors::ResourceNotFoundException
        false
      end
    end

    def runtime
      runtime_str = @conf.fetch('runtime') { raise ArgumentError.new('runtime must be set') }

      @runtime ||= Lamma::Runtime.new(runtime_str)
    end

    private

    def handler
      @conf.fetch('handler', default_handler)
    end

    def dead_letter_config
      @dead_letter_config ||= DeadLetterConfig.new(@conf.fetch('dead_letter_config', {}))
    end

    def environment
      @environment ||= Environment.new(@conf.fetch('environment', {}))
    end

    def vpc_config
      VpcConfig.new(@conf.fetch('vpc_config', {}))
    end

    def default_handler
      case runtime.type
      when Runtime::C_SHARP
        raise ValidationError.new('handler must be set for C# runtime')
      when Runtime::JAVA_8
        raise ValidationError.new('handler must be set for Java8 runtime')
      when Runtime::NODE_43
        'index.handler'
      when Runtime::EDGE_NODE_43
        'index.handler'
      when Runtime::PYTHON_27
        'lambda_function.lambda_handler'
      end
    end


    def lambda_client
      @lambda_client ||= Aws::Lambda::Client.new(region: @region)
    end
  end
end
