require 'pathname'
require 'inifile'


module Lamma
  module SharedHelpers
    DEFAULT_PROFILE = 'default'

    def ini_config(profile=DEFAULT_PROFILE)
      load_inifile(File.expand_path(File.join('~', '.aws', 'config')), profile)
    end

    def ini_credentials(profile=DEFAULT_PROFILE)
      load_inifile(File.expand_path(File.join('~', '.aws', 'credentials')), profile)
    end

    def region_or_raise(profile=DEFAULT_PROFILE)
      region = ENV['AWS_REGION'] ||
        ENV['AWS_DEFAULT_REGION'] ||
        ini_config(profile)['region']

      if region
        return region
      else
        raise Exception.new("Region must be specified by either AWS_REGION, AWS_DEFAULT_REGION or ~/.aws/config file")
      end
    end

    def search_conf_path(from)
      bn = File.basename(File.expand_path(from))
      dn = File.dirname(File.expand_path(from))
      pn = Pathname(dn)

      while pn != pn.parent
        cp = File.join(pn, bn)
        if File.exists?(cp)
          return cp
        end

        pn = pn.parent
      end

      ''
    end

    private

    def load_inifile(path, profile)
      if File.exists?(path)
        return IniFile.load(path)[profile]
      else
        {}
      end
    end
  end
end
