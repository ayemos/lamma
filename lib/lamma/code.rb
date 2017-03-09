require 'digest/md5'
require 'zip'

require 'lamma/logger'

module Lamma
  class Code
    BUILD_FILE_NAME = 'build.zip'

    def initialize(function, yaml)
      @function = function
      @source_path = yaml.fetch('source_path', '.')
      @prebuild = yaml.fetch('prebuild', nil)
      @build_path = yaml.fetch('build_path', nil)
    end

    def zip_io
      h = cached_build_hash

      if h
        bp = File.join(build_path, h, BUILD_FILE_NAME)
        Lamma.logger.info "Using cached build: #{bp}"
        @zip_io = File.open(bp, 'rb')
      else
        unless File.directory?(@source_path)
          raise "Source path #{@source_path} doesn't exists"
        end

        prebuild

        @zip_io = zip_and_save
      end

      @zip_io
    end

    def to_h
      {
        zip_file: zip_io
      }
    end

    private

    def zip_and_save
      io = Zip::OutputStream.write_buffer do |zio|
        active_paths.each do |path|
          next unless File.file?(path)
          File.open(path) do |source_io|
            zio.put_next_entry(path)
            data = source_io.read
            zio.write(data)
          end
        end
      end

      io.rewind

      if true # XXX: option save_builds?
        File.open(File.join(zipfile_path, BUILD_FILE_NAME), 'w').write(io.read)
        Lamma.logger.info("Saved the build: #{zipfile_path}")
        io.rewind
      end

      io
    end

    def prebuild
      if @prebuild
        Lamma.logger.info 'Running prebuild script...'
        raise unless system(@prebuild)
      elsif @function.runtime == Lamma::Runtime::PYTHON_27 \
        && File.exist?(File.join(@source_path, 'requirements.txt'))
        raise unless system("pip", "install", "-r", "requirements.txt", "-t", ".")
      elsif [Lamma::Runtime::EDGE_NODE_43, Lamma::Runtime::NODE_43].include?(@function.runtime) \
        && File.exist?(File.join(@source_path, 'package.json'))
        raise unless system("npm", "install", "--production")
      end
    end

    def cached_build_hash
      Dir.glob(File.join(build_path, "*/"))
        .map{|path| File.basename(path)}.each do |h|
        if hash == h
          return h
        end
      end

      nil
    end

    def hash
      return @hash if @hash

      h = Digest::MD5.new

      active_paths.each do |path|
        next unless File.file?(path)
        h.update(path)
        t = Digest::MD5.file(path)
        h.update(t.digest)
      end

      @hash = h.to_s
    end

    def active_paths
      Dir.glob(File.join(@source_path, '**/*')).select do |path|
        !ignores.include?(path)
      end
    end

    def build_path
      if @build_path
        unless File.directory?(@build_path)
          FileUtils.mkdir_p(@build_path)
        end
      else
        @build_path = File.join(Dir.tmpdir, 'lamma')
      end

      @build_path
    end

    def zipfile_path
      return @zipfile_path if @zipfile_path

      path = File.join(build_path, hash)
      unless File.directory?(path)
        FileUtils.mkdir_p(path)
      end

      @zipfile_path = path
    end

    def ignores
      # TODO: impl
      %w||
    end
  end
end
