puppet-pagerduty
================

Description
-----------

A Puppet report handler for sending notifications of failed runs to
[PagerDuty](http://www.pagerduty.com).  It includes sending all log data
in the `details` section of the API call.

Installation & Usage
-------------------

1. Install this module on your master node as `pagerduty`: `git submodule add git@github.com:PagerDuty/puppet-pagerduty.git /etc/puppetlabs/code/environments/production/modules/pagerduty`

1. Install the `puppetlabs-inifile` dependency: `/opt/puppetlabs/bin/puppet module install puppetlabs-inifile`

1. Install the gem dependencies on your master node:
    * `/opt/puppetlabs/server/bin/puppetserver gem install puppet`
    * `/opt/puppetlabs/server/bin/puppetserver gem install json`
    * `/opt/puppetlabs/server/bin/puppetserver gem install redphone`

1. Manually install pagerduty.rb to `/opt/puppetlabs/puppet/lib/ruby/vendor_ruby/puppet/reports/` by copying the script into the directory.
    This is due to the Puppet issue documented [here](https://tickets.puppetlabs.com/browse/SERVER-1014)

1. Restart the `puppetserver` service

1. Create a Puppet specific service that uses the Puppet integration in PagerDuty

1. Add the `pagerduty` class to your master node's main manifest:

         class { 'pagerduty' }

1. List `pagerduty` as a report handler on your master node in `puppet.conf`:

         [master]
         reports = pagerduty

1. Enable pluginsync and reports on your master and client nodes if it is not already:

    You can manually enable in `puppet.conf`:

         [master]
         report = true
         pluginsync = true
         [agent]
         report = true
         pluginsync = true

    Or you can enable within the `pagerduty` class in your master node's manifest:

        class { 'pagerduty':
          pagerduty_puppet_reports    => 'store,http,pagerduty',
          pagerduty_puppet_pluginsync => 'true',
        }

    **Note:** The step above is optional. These settings are `true` by default as of Puppet 3.0.0.

1. Run the Puppet client and sync the report as a plugin: `/opt/puppetlabs/bin/puppet agent --test`

Author
------

James Turnbull <james@lovedthanlost.net>

License
-------

    Author:: James Turnbull (<james@lovedthanlost.net>)
    Copyright:: Copyright (c) 2011 James Turnbull
    License:: Apache License, Version 2.0

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
