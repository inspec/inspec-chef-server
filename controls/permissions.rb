# These permissions should be enforced by the cookbooks used by
# `chef-server-ctl reconfigure`, however sometimes that doesn't get
# run regularly.
describe directory('/etc/opscode') do
  its('owner') { should eq 'root' }
  its('group') { should eq 'root' }
  its('mode') { should cmp '0755' }
end

control 'private keys' do
  desc 'Permissions of the private keys *.pem in /etc/opscode'

  describe file('/etc/opscode/pivotal.pem') do
    its('owner') { should eq 'opscode' }
    its('group') { should eq 'root' }
    its('mode') { should cmp '0600' }
  end

  describe file('/etc/opscode/webui_priv.pem') do
    its('owner') { should eq 'opscode' }
    its('group') { should eq 'root' }
    its('mode') { should cmp '0600' }
  end

  describe file('/etc/opscode/webui_pub.pem') do
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('mode') { should cmp '0644' }
  end
end

control 'configuration files' do
  desc 'Permissions of configuration files in /etc/opscode'

  describe file('/etc/opscode/chef-server.rb') do
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('mode') { should cmp '0640' }
  end

  describe file('/etc/opscode/chef-server-running.json') do
    its('owner') { should eq 'opscode' }
    its('group') { should eq 'root' }
    its('mode') { should cmp '0600' }
  end

  describe file('/etc/opscode/dark_launch_features.json') do
    its('owner') { should eq 'opscode' }
    its('group') { should eq 'root' }
    its('mode') { should cmp '0644' }
  end

  describe file('/etc/opscode/pivotal.rb') do
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('mode') { should cmp '0644' }
  end

  describe file('/etc/opscode/private-chef-secrets.json') do
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('mode') { should cmp '0600' }
  end
end
