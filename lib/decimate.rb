require "decimate/version"

module Decimate
  def self.shred_cmd; "shred -uv"; end
  def self.shred_errs_log; '/tmp/decimate_shred_errs'; end

  def self.run cmd
    system cmd
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
 
    run "#{shred_cmd} #{path} &> #{shred_errs_log}"
  end

  def self.dir! path, opts={}
    fail_unless_shred
    return unless Dir.exist?(path)
    raise 'must provide a directory' unless File.directory?(path)
    validate_path path, opts[:path_must_match]
    
    run "find #{path} -type f -execdir #{shred_cmd} '{}' ';' &> #{shred_errs_log}"
    FileUtils.rm_rf path
  end
end
