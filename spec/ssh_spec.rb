require File.join(File.dirname(__FILE__), 'spec_helper.rb')

class SSHManifest < Moonshine::Manifest
  plugin :ssh
end

describe SSH do
  
  before do
    @manifest = SSHManifest.new
  end
  
  
  it "should be executable" do
    @manifest.should be_executable
  end
  
  it "should load the template file" do
    File.should_receive(:read).with(File.expand_path(File.join(File.dirname(__FILE__), '..', 'templates', 'sshd_config'))).and_return "SSH CONFIG"
    @manifest.ssh
  end
  
  it "should set default values" do
    @manifest.ssh
    @manifest.puppet_resources[Puppet::Type::File].should include("/etc/ssh/sshd_config.new")
    sshd_config = @manifest.puppet_resources[Puppet::Type::File]["/etc/ssh/sshd_config.new"][:content]
    sshd_config.should match /Port 22/
    sshd_config.should match /PermitRootLogin no/
  end
  
  it "should check the configuration file before updating" do
    @manifest.ssh
    @manifest.puppet_resources[Puppet::Type::Exec].should include("mv /etc/ssh/sshd_config.new /etc/ssh/sshd_config")
    @manifest.puppet_resources[Puppet::Type::Exec]["mv /etc/ssh/sshd_config.new /etc/ssh/sshd_config"][:onlyif].should_not be_nil
  end

  it "should allow customization" do
    @manifest.ssh( :port => 9022 )
    @manifest.puppet_resources[Puppet::Type::File]["/etc/ssh/sshd_config.new"][:content].should match /Port 9022/
  end
    
end