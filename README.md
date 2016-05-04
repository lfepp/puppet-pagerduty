puppet-pagerduty
================

Description
-----------

A Puppet report handler for sending notifications of failed runs to
[PagerDuty](http://www.pagerduty.com).  It includes sending all log data
in the `details` section of the API call.

Installation & Usage
-------------------

1. Install dependencies on all Puppet master nodes: `/opt/puppetlabs/server/bin/puppetserver gem install GEM_NAME`

1. Manually install pagerduty.rb to /opt/puppetlabs/puppet/lib/ruby/vendor_ruby/puppet/reports/
   This is due to a [bug](https://tickets.puppetlabs.com/browse/SERVER-1014)

1. Restart puppetserver service

1. You will need to create a Puppet specific service that uses the
   Generic API in PagerDuty.

1. Add the class to the puppet master node:

         class { 'pagerduty':
           pagerduty_puppet_api => 'YOUR PAGERDUTY API HERE',
         }


Not Madatory, it is the default since Puppet 3.0.0
1. Enable pluginsync and reports on your master and clients in `puppet.conf`

   You can do it manually:

         [master]
         report = true
         reports = pagerduty
         pluginsync = true
         [agent]
         report = true
         pluginsync = true

   Or use the class:

         class { 'pagerduty':
           pagerduty_puppet_api        => 'YOUR PAGERDUTY API HERE',
           pagerduty_puppet_reports    => 'store,http,pagerduty',
           pagerduty_puppet_pluginsync => 'true',
         }

1. Run the Puppet client and sync the report as a plugin

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
