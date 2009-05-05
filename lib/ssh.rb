module SSH

  # Ensures the SSH server is installed, running, and configured
  # per specifications. Use <tt>configure</tt> to change defaults.
  # The available options can be gathered by perusing the sshd_config
  # template.
  #
  #   configure(:ssh => {:permit_root_login => 'yes', :port => 9022})
  #
  def ssh(options = {})
    package 'ssh', :ensure => :installed
    service 'ssh', :enable => true, :ensure => :running
    
    file '/etc/ssh/sshd_config.new',
      :mode => '644',
      :content => template(File.join(File.dirname(__FILE__), '..', 'templates', 'sshd_config'), binding),
      :require => package('ssh')
    
    exec 'cp /etc/ssh/sshd_config.new /etc/ssh/sshd_config',
      :onlyif => '/usr/sbin/sshd -t -f /etc/ssh/sshd_config.new',
      :unless => 'test `diff sshd_config sshd_config.new | wc -l` -eq 0',
      :require => file('/etc/ssh/sshd_config.new'),
      :notify => service('ssh')
  end
  
end