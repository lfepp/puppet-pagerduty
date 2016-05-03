# Report processor integration with PagerDuty
class pagerduty(
  $pagerduty_puppet_api        = 'SET ME',
  $pagerduty_puppet_reports    = undef,
  $pagerduty_puppet_pluginsync = undef,
  $pagerduty_puppet_service    = undef,
) {

  if ! defined(Service[$pagerduty_puppet_service]) {
    service { $pagerduty_puppet_service :
      ensure => running,
    }
  }

  file { "${::facts['pd_puppet_conf_base']}/pagerduty.yaml":
    path    => "${::facts['pd_puppet_conf_base']}/pagerduty.yaml",
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('pagerduty/pagerduty.yaml.erb'),
  }

  if $pagerduty_puppet_reports {
    ini_setting { 'pagerduty_puppet_reports':
      ensure  => present,
      path    => "${::facts['pd_puppet_conf_base']}/puppet.conf",
      section => master,
      setting => reports,
      value   => $pagerduty_puppet_reports,
      notify  => $pagerduty_puppet_service ? {
        undef   => undef,
        default => Service[$pagerduty_puppet_service],
      },
    }
  }

  if $pagerduty_puppet_pluginsync {
    ini_setting { 'pagerduty_puppet_pluginsync':
      ensure  => present,
      path    => "${::facts['pd_puppet_conf_base']}/puppet.conf",
      section => main,
      setting => pluginsync,
      value   => $pagerduty_puppet_pluginsync,
      notify  => $pagerduty_puppet_service ? {
        undef   => undef,
        default => Service[$pagerduty_puppet_service],
      },
    }
  }

}
