# Archived Repository
This repository has been archived and will no longer receive updates. 
It was archived as part of the [Repository Standardization Initiative](https://github.com/chef-boneyard/oss-repo-standardization-2025).
If you are a Chef customer and need support for this repository, please contact your Chef account team.

# Chef Server Inspec Profile

This repository is an Inspec profile for testing the health of Chef Servers.

This profile does not perform compliance tests. It is intended to be used in assessing whether a target node for a Chef Server is set up correctly to meet the [documented prerequisites](https://docs.chef.io/install_server_pre.html), verify that the external API is functioning correctly, that file permissions haven't been changed errantly, and that there aren't any "red flags" that we've encountered that cause issues for customers.

This Inspec profile is not a substitute for adequate performance and system health monitoring. It can supplement those tools well, however.

# Controls

### prerequisites.rb

This set of controls implements tests for the various [prerequisites](https://docs.chef.io/install_server_pre.html) for installing a Chef Server.

### permissions.rb

This set of controls tests that the file permissions on various configuration and secrets hasn't deviated in the case of Chef Servers that were "set up once" with `chef-server-ctl reconfigure`, and then "not touched again."

### chef-server.rb

This set of controls tests the health of the Chef Server API. For example:

* Check the API is HTTPS accessible with a valid certificate
* Verify no organizations are "empty" (zero nodes)
* Does not have cookbooks with an excessive number of versions

These are issues we've identified with customers who have attempted to backup/restore, or upgrade their Chef Servers. There are configurable attributes. See the Usage section below.

# Usage

Run the full profile against the target Chef Server's IP. For example, after standing up a local VM with test kitchen in the [chef-server](https://supermarket.chef.io/cookbooks/chef-server) cookbook:

```
inspec exec --target=ssh://172.16.227.129 --user=vagrant --attrs  files/local.yml --sudo .
```

The `--sudo` option is required because the profile needs to read root-read-only files in `/etc/opscode`. See [Configuration](#Configuration) below for more information about `--attrs files/local.yml`.

## Configuration

The following profile attributes can be set in a YAML file. They are used in the `chef-server.rb` controls.

* `api_fqdn`: The API FQDN for the Chef Server
* `client_name`: The API Client of the Chef Server Admin
* `signing_key_filename`: Private Key of the API Client
* `trusted_certs_dir`: Location for Trusted SSL Certificates
* `count_cookbook_versions`: Whether to count all cookbook versions, could be long running

# License and Author

* Author: Joshua Timberman [joshua@chef.io](mailto:joshua@chef.io)

```text
Copyright 2017, Chef Software, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
