require 'aws-sdk'
require 'uri'
require 'json'
require 'pathname'

require 'lamma/logger'
require 'lamma/runtime'
require 'lamma/shared_helpers'

module Lamma
  class CLI::Init
    include Thor::Actions
    include Lamma::SharedHelpers

    ROLE_ARN_PLACEHOLDER = 'YOUR_ROLE_ARN'

    DEFAULT_LAMBDA_ASSUME_ROLE_POLICY =
      {
        'Version': '2012-10-17',
        'Statement':
        [
          {
            'Effect': 'Allow',
            'Principal':
            {
              'Service': 'lambda.amazonaws.com'
            },
            'Action': 'sts:AssumeRole',
          },
        ],
      }

    attr_reader :target, :thor, :options, :runtime, :function_name

    def initialize(options, function_name, thor)
      @options = options
      @thor = thor
      runtime_str = options.fetch('runtime') { raise ArgumentError.new('runtime must be set.') }
      @runtime = Lamma::Runtime.new(runtime_str)
      @function_name = function_name
      @target = Pathname.pwd.join(function_name)
    end

    def run
      if Dir.exist?(target)
        abort("Directory '#{target}' already exists.")
      end

      tpath = File.join(File.dirname(__FILE__), '..', 'templates', runtime.to_dirname)
      templates = Dir.glob(File.join(tpath, '**/*.erb')).map do |path|
        tar_file = path[tpath.length..path.length - 5] # /foo/bar/templates/RUNTIME/baz/lambda_function.py.erb => /baz/lambda_function.py

        [File.expand_path(path), File.join(target, tar_file)]
      end.to_h

      unless Dir.exist?(target)
        FileUtils.makedirs(target)
      end

      role_arn = options['role_arn']

      unless role_arn
        role_name = "#{function_name}-lamma-role"
        thor.say("Looks like you didn't specified role arn for the function.", :yellow)
        y_or_n = thor.ask("Do you want me to create default IAM role and configure it (#{role_name})? (y/n)", :yellow)

        if y_or_n =~ /^[yY]/
          role_arn = create_initial_role(role_name)
        else
          role_arn = 'YOUR_ROLE_ARN'
        end
      end

      templates.each do |src, dst|
        thor.say_status(:create, dst)

        File.open(dst, "w") do |f|
          template = File.read(src)
          formatted = ERB.new(template).result(binding)
          f.write(formatted)
        end
      end


      Lamma.logger.info "Initializing git repo in #{target}"
      Dir.chdir(target) do
        `git init`
        `git add .`
      end
    end

    private

    def iam
      Aws::IAM::Client.new
    end

    def create_initial_role(role_name)
      begin
        Lamma.logger.info("Creating role #{role_name}")
        resp = iam.create_role({
          assume_role_policy_document: DEFAULT_LAMBDA_ASSUME_ROLE_POLICY.to_json,
          path: "/",
          role_name: role_name
        })
      rescue Aws::IAM::Errors::EntityAlreadyExists
        thor.say("Role #{role_name} seems to be created before", :yellow)
        y_or_n = thor.ask("Do you want me to configure the role (#{role_name})? (y/n)", :yellow)

        unless y_or_n =~ /^[yY]/
          return ROLE_ARN_PLACEHOLDER
        end
      end

      Lamma.logger.info("Checking attached role policies for #{role_name}")

      g_resp = iam.get_role({
        role_name: role_name
      })
      role_arn = g_resp.role.arn

      unless iam.list_attached_role_policies({role_name: role_name }).attached_policies
        .any?{|po| po.policy_name == 'AWSLambdaBasicExecutionRole'}
        Lamma.logger.info('Could not find AWSLambdaBasicExecutionRole policy. Attatching.')

        Lamma.logger.info("Attaching minimal policy (AWSLambdaBasicExecutionRole) to #{role_name}")
        resp = iam.attach_role_policy({
          policy_arn: 'arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole',
          role_name: role_name
        })

        Lamma.logger.info("Done")
      end

      role_arn
    end
  end
end
