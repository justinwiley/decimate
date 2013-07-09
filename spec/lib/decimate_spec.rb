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
  let(:stdout) { 'sample stddout' }

  shared_context 'existing_files_and_dir' do
    before do
      FileUtils.mkdir_p subdir
      all_files.each{|f| FileUtils.touch f}
    end

    after do
      FileUtils.rm_rf(dir) if File.exist?(dir)
    end
  end

  describe '#validate_path' do
    it 'should expand and return path' do
      Decimate.validate_path(file).should == File.expand_path(file)
    end

    it 'should raise if expanded path matches /' do
      expect{Decimate.validate_path('/')}.to raise_error
      expect{Decimate.validate_path('/dir/../')}.to raise_error
    end
    context 'with required path match argument' do
      it 'should return path if expanded path matches given' do
        Decimate.validate_path(file, /tmp/).should == File.expand_path(file)
      end

      it 'should raise if not' do
        expect{Decimate.validate_path(file, /another_dir/)}.to raise_error
      end
    end
  end

  describe '#fail_unless_shred' do
    it 'should raise if no shred' do
      Decimate.should_receive(:`).with("which shred").and_return("")
      expect{Decimate.fail_unless_shred}.to raise_error
    end

    it 'should not raise if shred' do
      Decimate.should_receive(:`).with("which shred").and_return("shred")
      Decimate.fail_unless_shred
    end
  end
  
  describe '#file' do
    include_context 'existing_files_and_dir'

    it 'should check for shred' do
      Decimate.should_receive(:fail_unless_shred)
      Decimate.file! file
    end

    it 'should securely delete the given file' do
      Open3.should_receive(:capture3).with("shred -uv #{file}").and_return([stdout,"",nil])
      Decimate.file!(file).should == stdout
    end

    it 'should result in file being removed' do
      File.exist?(file3).should be_true
      Decimate.file! file3
      sleep 2  # shred operation takes a while
      File.exist?(file3).should be_false
    end
  end

  describe '#dir' do
    include_context 'existing_files_and_dir'

    it 'should check for shred' do
      Decimate.should_receive(:fail_unless_shred)
      Decimate.dir! dir
    end

    it 'should securely delete all files under the given file' do
      Open3.should_receive(:capture3).with("find #{dir} -type f -exec shred -uv {} +")
      Decimate.dir! dir
    end

    it 'should result in all files and dirs being deleted' do
      all_files.map{|f| File.exist?(f).should be_true}
      Decimate.dir! dir
      all_content.each do |f|
        File.exist?(f).should be_false
      end
    end

  end

end