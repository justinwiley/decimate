require "decimate/version"
require 'fileutils'
require 'open3'

module Decimate
  def self.shred_cmd; "shred -uv"; end
  def self.shred_errs_log; '/tmp/decimate_shred_errs'; end

  def self.run cmd
    stdout,stderr,status = Open3.capture3 cmd
    unless status.nil? || status == 0
      raise "failed #{cmd}"
      File.open(stred_errs_log){|f| f.write(stdout); f.write(stderr); }
    end
    stdout
  end

  def self.validate_path path, required_regex=nil
    raise ArgumentError.new("expected Regexp, given #{required_regex.class}") if required_regex && !required_regex.is_a?(Regexp)
    File.expand_path(path).tap do |path|
      raise ArgumentError.new("It looks like you're trying to remove root dir, got #{path}") if path == '/'
      raise ArgumentError.new("Path #{path} does not match #{required_regex}") if required_regex && !path.match(required_regex)
    end
  end

  def self.fail_unless_shred
    raise if `which shred`.chomp.empty?
  end


  def self.file! path, opts={}
    fail_unless_shred
    return unless File.exist?(path)
    raise 'must provide a file' unless File.file?(path)
    validate_path path, opts[:path_must_match]
 
    run "#{shred_cmd} #{path}"
  end

  def self.dir! path, opts={}
    fail_unless_shred
    return unless Dir.exist?(path)
    raise 'must provide a directory' unless File.directory?(path)
    validate_path path, opts[:path_must_match]
    
    stdout = run "find #{path} -type f -execdir #{shred_cmd} '{}' ';'"
    FileUtils.rm_rf path
    stdout
  end
end
