api_fqdn                = attribute('api_fqdn', default: 'localhost', description: 'The API FQDN for the Chef Server')
client_name             = attribute('client_name', default: 'pivotal', description: 'The API Client of the Chef Server Admin')
signing_key_filename    = attribute('signing_key_filename', default: '/etc/opscode/pivotal.pem', description: 'Private key of the API Client')
trusted_certs_dir       = attribute('trusted_certs_dir', default: '/etc/chef/trusted_certs_dir', description: 'Loation for trusted SSL certificates')
count_cookbook_versions = attribute('count_cookbook_versions', default: false, description: 'Whether to count all cookbook versions, could be long running')

org_list = command('chef-server-ctl org-list').stdout.split

control "API available via HTTPS #{api_fqdn}" do
  desc 'The Chef Server API must be available via HTTPS. Insecure mode is ok here as we check the cert in a later control.'

  describe command("curl -s -o /dev/null -w '%{http_code}' -k https://#{api_fqdn}") do
    its('stdout') { should eq '200' }
  end
end


control 'SSL certificate is trusted' do
  desc '
    The SSL certificate should be trusted. This can be from performing
    a `knife ssl fetch`, or by using a validated certificate.
  '
  opts = "--config-option trusted_certs_dir=#{trusted_certs_dir}"

  describe command("knife ssl check -s https://#{api_fqdn} #{opts}") do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/Successfully verified certificates.*#{api_fqdn}/) }
  end
end

control 'No empty organizations' do
  desc 'Empty organizations contribute to backup/restore issues for upgrading Chef Servers'

  org_list.each do |org|
    opts = "-s https://#{api_fqdn}/organizations/#{org}"
    opts << " -k #{signing_key_filename} -u #{client_name}"
    opts << " --config-option trusted_certs_dir=#{trusted_certs_dir} 2>/dev/null"

    describe command("knife node list #{opts}") do
      its(:stdout) { should match(/\w+/) }
    end
  end
end

control 'Does not have excess cookbook versions' do
  only_if {count_cookbook_versions}
  desc '
    Having too many versions of cookbooks leads to problems with
    backing up and restoring Chef Server data for upgrades and
    maintenance
  '

  org_list.each do |org|
    opts = "-s https://#{api_fqdn}/organizations/#{org}"
    opts << " -k #{signing_key_filename} -u #{client_name}"
    opts << " --config-option trusted_certs_dir=#{trusted_certs_dir} 2>/dev/null"

    cookbook_list = command("knife cookbook list #{opts} | cut -f1 -d' '").stdout.split

    cookbook_list.each do |cb|
      describe command("knife cookbook show #{cb} #{opts}") do
        its('stdout.split.count') { should be < 30 }
      end
    end
  end
end
