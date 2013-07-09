require "decimate/version"
require 'shellwords'
require 'fileutils'
require 'open3'

module Decimate
  def self.shred_cmd; "shred -uv"; end
  #
  # Executes given command using Open3.capture3
  # Raises exception if non-zero status call returned, writes to error log
  # 
  def self.run cmd
    stdout,stderr,status = Open3.capture3 cmd
    raise "Failed executing #{cmd}: stdout: #{stdout}, stderr: #{stderr}, status #{status}" unless status.nil? || status == 0
    stdout
  end

  # Check for shred, escape path, ensure path isn't root dir or fails regexp
  def self.validate path, required_regex=nil
    fail_unless_shred
    escaped_path = Shellwords.escape path
    validate_path escaped_path, required_regex
  end

  def self.validate_path path, required_regex=nil
    File.expand_path(path).tap do |path|
      raise "Trying to remove root dir?  Path: #{path}" if path == '/'
      raise "Path #{path} does not match #{required_regex}" if required_regex && !path.match(required_regex)
    end
  end

  def self.fail_unless_shred
    raise if `which shred`.chomp.empty?
  end

  #
  # Securely deletes given file using shred.
  #
  #  - Returns nil if file does not exist
  #  - Returns stdout from shred operation if file exists and shredded successfully
  #  - If optional regex sanity check is included, exception will be raised if match against given path fails
  #  - Raises if shred or find command triggers any status code other than zero
  #  - Raises if shred command not found
  #
  def self.file! path, opts={}
    return unless File.exist?(path)
    path = validate path, opts[:path_must_match]

    run "#{shred_cmd} #{path}"
  end

  #
  # Securely deletes given directory recursively using shred.
  #
  #  - Returns nil if directory does not exist
  #  - Returns stdout from shred operation if dir exists and shredded successfully
  #  - If optional regex sanity check is included, exception will be raised if match against given path fails
  #  - Raises if shred or find command triggers any status code other than zero
  #  - Raises if shred command not found
  #
  # Usage:
  # Decimate.dir! 'my-unloved-dirctory'
  # Decimate.dir! 'my-unloved-dirctory', path_must_match: /unloved/
  #
  def self.dir! path, opts={}
    return unless Dir.exist?(path)
    path = validate path, opts[:path_must_match]

    stdout = run "find #{path} -type f -exec #{shred_cmd} {} +"
    FileUtils.rm_rf path
    stdout
  end
end
