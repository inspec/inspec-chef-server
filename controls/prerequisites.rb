control 'Supported Hardware Architecture' do
  desc '
    Chef Server installation prerequisites require that foundational platforms be
    64 bit or S390 (SUSE only) architecture.

    https://docs.chef.io/install_server_pre.html
  '

  # TODO: (jtimberman) suse can also be `s390x`
  describe os.arch do
    it { should eq 'x86_64' }
  end
end

control 'Hostnames' do
  # TODO: (jtimberman) Support fqdn in inspec's `sys_info` resource
  desc '
    Ensure that systems have properly configured hostnames. The server hostname
    must be an FQDN, including the domain suffix, and must be resolvable.
  '

  describe host(sys_info.hostname) do
    it { should be_reachable }
    it { should be_resolvable }
  end

  describe command('hostname -f') do
    its(:stdout) { should match(/^([[:digit:]]|[[:lower:]]|\.|-|_)+/) }
    its(:exit_status) { should eq 0 }
  end
end

control 'Mail Relay' do
  desc '
    The Chef server uses email to send notifications for various
    events; a local mail transfer agent should be installed and
    available to the Chef server
  '

  describe.one do
    describe package('postfix') do
      it { should be_installed }
    end

    describe package('exim') do
      it { should be_installed }
    end
  end

  describe.one do
    describe service('postfix') do
      it { should be_running }
    end

    describe service('exim') do
      it { should be_running }
    end
  end
end

control 'cron' do
  desc 'Periodic maintenance tasks are performed using cron'

  describe.one do
    describe service('cron') do
      it { should be_running }
    end

    describe service('crond') do
      it { should be_running }
    end
  end
end

control 'git' do
  desc 'git must be installed so that various internal services can confirm revisions'

  describe package('git') do
    it { should be_installed }
  end

  describe command('git --version') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/^git version/) }
  end
end

control 'libfreetype and libpng' do
  desc 'these libraries are required'

  describe.one do
    describe package('libpng') do
      it { should be_installed }
    end

    describe package('libpng12-0') do
      it { should be_installed }
    end
  end

  describe.one do

  end
end

control 'NTP' do
  desc '
    Ensure that every server is connected to NTP.
    The Chef server is sensitive to clock drift
  '

  describe.one do
    describe service('ntp') do
      it  { should be_running }
    end

    describe service('ntpd') do
      it  { should be_running }
    end
  end
end

control 'Disable Qpid on RHEL' do
  desc '
    This daemon must be disabled on CentOS and Red Hat systems
  '
  only_if do
    os.redhat?
  end

  describe service('qpid') do
    it { should_not be_running }
  end
end

### Hardware Considerations - standalone only
# TODO: (jtimberman) frontend and backend
control 'Memory' do
  desc '8 GB of RAM or more'

  memtotal = file('/proc/meminfo').content.split(/\n/).grep(/MemTotal:/)[0].split[1].to_i / 1024
  describe memtotal do
    it { should cmp >= 8096 }
  end
end

control 'CPU Cores' do
  desc '4 processor cores, physical or virtual'

  processors = file('/proc/cpuinfo').content.split(/\n/).grep(/^processor/).count
  describe processors do
    it { should cmp >= 4 }
  end
end

control 'Free filesystem space' do
  desc '5GB free in /opt and /var'

  # these might even be the same filesystem - `/` - of course
  opt_df = command('df -m -l --output=avail /opt | grep -v Avail').stdout
  describe opt_df do
    it { should cmp >= 5000 }
  end

  var_df = command('df -m -l --output=avail /var | grep -v Avail').stdout
  describe var_df do
    it { should cmp >= 5000 }
  end
end

control 'SELinux' do
  only_if do
    os.redhat?
  end

  desc '
    The Chef server does not have a profile available to run under
    SELinux. In order for the Chef server to run, SELinux must be
    disabled or set to Permissive mode.
  '

  describe.one do
    describe command('/sbin/getenforce') do
      its('stdout') { should match(/^Permissive/) }
    end

    describe command('/sbin/getenforce') do
      its('stdout') { should match(/^Disabled/) }
    end
  end
end

# TODO: (jtimberman) test and implement this properly
control 'AppArmor' do
  only_if do
    os.name == 'ubuntu' && command('/usr/sbin/aa-status').exist? && ! command('/usr/sbin/aa-status').stdout.empty?
  end

  desc '
    Chef products do not have a profile available to run under
    AppArmor. In order for the Chef products to run, AppArmor must set
    to Complaining mode or disabled.
  '

  describe command("aa-status") do
    its('stdout') { should match(/0 (processes|profiles) are in enforce mode/) }
  end
end
