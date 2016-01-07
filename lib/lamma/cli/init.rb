require 'pathname'
require 'lamma/runtime'

module Lamma
  class CLI::Init
    include Thor::Actions
    attr_reader :target, :thor, :options, :runtime

    def initialize(options, function_name, thor)
      @options = options
      @thor = thor
      runtime_str = options.fetch('runtime') { raise ArgumentError.new('runtime must be set.') }
      @runtime = Lamma::Runtime.new(runtime_str)
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

      unless Dir.exists?(target)
        FileUtils.makedirs(target)
      end

      templates.each do |src, dst|
        File.open(dst, "w") do |f|
          template = File.read(src)
          formatted = ERB.new(template).result(binding)
          f.write(formatted)
        end
      end

      Dir.chdir(target) do
        `git init`
        `git add .`
      end
    end
  end

  private

  def default_region
    'us-east-1'
  end

  def default_account_id
    nil
  end

  def default_role_name
    nil
  end
end
