class apache {

  include apache::config

  # Bring default plist under our control - taken from Mountain Lion 10.8.2
  file { '/System/Library/LaunchDaemons/org.apache.httpd.plist':
    content => template('apache/org.apache.httpd.plist.erb'),
    group   => 'wheel',
    notify  => Service['org.apache.httpd'],
    owner   => 'root'
  }

  # Add all the directories and files Apache is expecting
  # Most of these should already exist on Mountain Lion

  file { [
    $apache::config::configdir,
    $apache::config::logdir,
    $apache::config::sitesdir,
  ]:
    ensure => directory,
    owner  => root,
    group  => wheel,
  }

  file { $apache::config::configfile:
    content => template('apache/config/apache/httpd.conf.erb'),
    notify  => Service['org.apache.httpd'],
    owner   => root,
    group   => wheel
  }

  service { "org.apache.httpd":
    ensure => running,
    require => File[$apache::config::configfile]
  }

  apache::vhost { 'localhost':
    docroot  => "${boxen::config::srcdir}",
    host     => "localhost",
    port     => $apache::config::port,
  }
  
  apache::vhost { 'dnsmasq':
    docroot  => "${boxen::config::srcdir}",
    port     => $apache::config::port,
    template => "vhost_dnsmasq.conf",
  }
}