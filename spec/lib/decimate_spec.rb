require 'spec_helper'
require 'fileutils'

describe Decimate do
  let(:dir) { "tmp" }
  let(:subdir) { "tmp/subdir" }
  let(:file) { "#{dir}/file.txt"}
  let(:file2) { "#{dir}/file2.txt"}
  let(:file3) { "#{subdir}/file3.txt"}
  let(:all_files) { [file, file2, file3] }
  let(:all_content) { [dir, subdir] + all_files }

  shared_context 'existing_files_and_dir' do
    before do
      FileUtils.mkdir_p subdir
      all_files.each{|f| FileUtils.touch f}
    end

    after do
      FileUtil.rm_rf(dir) if File.exist?(dir)
    end
  end

  describe '#validate_path' do
    it 'should expand and return path' do
      Decimate.validate_path(file).should == File.expand_path(file)
    end

    it 'should raise if expanded path matches /' do
      expect{Decimate.validate_path('/')}.to raise_error(ArgumentError)
      expect{Decimate.validate_path('/dir/../')}.to raise_error(ArgumentError)
    end
    context 'with required path match argument' do
      it 'should return path if expanded path matches given' do
        Decimate.validate_path(file, 'tmp').should == File.expand_path(file)
      end

      it 'should raise if not' do
        expect{Decimate.validate_path(file, 'another_dir')}.to raise_error(ArgumentError)
      end
    end
  end

  describe '#fail_unless_shred' do
    it 'should raise if no shred' do
      Kernel.should_receive(:`).with("which shred").and_return("")
      expect{Decimate.fail_unless_shred}.to raise_error
    end

    it 'should not raise if shred' do
      Kernel.should_receive(:`).with("which shred").and_return("shred")
    end
  end
  
  describe '#file' do
    shared_context 'existing_files_and_dir'

    it 'should check for shred' do
      Decimate.should_receive(:fail_unless_shred)
      Decimate.file
    end

    it 'should securely delete the given file' do
      Kernel.should_receive(:`).with("shred -u #{file}")
      Decimate.file file
    end

    it 'should result in file being removed' do
      File.exist?(file).should be_true
      Decimate.file file
      File.exist?(file).should be_false
    end
  end

  describe '#dir' do
    shared_context 'existing_files_and_dir'

    it 'should check for shred' do
      Decimate.should_receive(:fail_unless_shred)
      Decimate.dir
    end

    it 'should securely delete all files under the given file' do
      Kernel.should_receive(:`).with("find #{dir} -type f -execdir shred -u '{}' \;")
      Decimate.dir dir
    end

    it 'should result in all files and dirs being deleted' do
      all_content.each do |f|
        File.exist?(f).should be_false
      end
    end

  end

end