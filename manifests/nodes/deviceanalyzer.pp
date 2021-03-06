#Configuration for deviceanalyzer related stuff

$deviceanalyzer_ips = dnsLookup('deviceanalyzer.dtg.cl.cam.ac.uk')
$deviceanalyzer_ip = $deviceanalyzer_ips[0]

node 'deviceanalyzer.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'

  # open up ports 80,443,2468
  class {'dtg::firewall::publichttp':}
  class {'dtg::firewall::publichttps':}
  firewall { '030-xmlsocketserver accept tcp 2468 (xmlsocketserver) from anywhere':
    proto  => 'tcp',
    dport  => 2468,
    action => 'accept',
  }

  # Packages which should be installed
  $packagelist = ['openjdk-7-jdk', 'jetty8', 'nginx', 'autofs']
  package {
    $packagelist:
      ensure => installed
  }

  file {'/etc/auto.mnt':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => 'a=r',
    content => 'nas01   nas01.dtg.cl.cam.ac.uk:/data/deviceanalyzer
nas02   nas02.dtg.cl.cam.ac.uk:/volume1/deviceanalyzer
nas04   nas04.dtg.cl.cam.ac.uk:/dtg-pool0/deviceanalyzer
nas04-index   nas04.dtg.cl.cam.ac.uk:/dtg-pool0/deviceanalyzer-datadivider ',
  } ->
  file_line {'mount nas':
    line => '/mnt   /etc/auto.mnt',
    path => '/etc/auto.master',
  }

  file {'/nas1':
    ensure => link,
    target => '/mnt/nas01',
  }
  file {'/nas2':
    ensure => link,
    target => '/mnt/nas02',
  }
  file {'/nas4':
    ensure => link,
    target => '/mnt/nas04',
  }
  file {'/nas4-index':
    ensure => link,
    target => '/mnt/nas04-index',
  }


  # mount nas02 on startup
  file_line { 'mount nas02':
    line   => 'nas02.dtg.cl.cam.ac.uk:/volume1/deviceanalyzer /nas2 nfs defaults 0 0',
    path   => '/etc/fstab',
    ensure => absent,
  }

  # mount nas04 on startup
  file_line { 'mount nas04':
    line   => 'nas04.dtg.cl.cam.ac.uk:/dtg-pool0/deviceanalyzer /nas4 nfs defaults 0 0',
    path   => '/etc/fstab',
    ensure => absent,
  }

  # set up nginx and jetty config
  file {'/etc/nginx/sites-enabled/default':
    ensure => absent,
  }
  file {'/etc/nginx/sites-enabled/deviceanalyzer.nginx.conf':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/dtg/deviceanalyzer/deviceanalyzer.nginx.conf',
  }
  file {'/etc/default/jetty8':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/dtg/deviceanalyzer/jetty8',
  }
  file {'/etc/init.d/xmlsocketserver':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/dtg/deviceanalyzer/xmlsocketserver.initd',
  }
  file {'/etc/network/interfaces':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/dtg/deviceanalyzer/interfaces',
  }

  # ensure webapps directory is writeable by the non-standard 'www-data' user
  file { '/var/lib/jetty8/webapps':
    ensure => directory,
    owner  => 'www-data',
    group  => 'www-data',
    mode   => '0755',
  }
}

node 'deviceanalyzer-database.dtg.cl.cam.ac.uk' {
# MAC: 00:0e:0c:bc:0e:e4
# IPv4: 128.232.23.47

  include 'dtg::minimal'
  class { 'postgresql::globals':
    version => '9.4',
  }
  ->
  class { 'postgresql::server':
    ip_mask_deny_postgres_user => '0.0.0.0/0',
    ip_mask_allow_all_users    => '127.0.0.1/32',
    listen_addresses           => '*',
    ipv4acls                   => ['hostssl all all 127.0.0.1/32 md5',
                                   'host androidusage androidusage 128.232.98.188/32 md5']
  }
  ->
  postgresql::server::db{'androidusage':
    user     => 'androidusage',
    password => 'androidusage',
    encoding => 'UTF-8',
    grant    => 'ALL'
  }
  ->
  postgresql::server::db{'androidstats':
    user     => 'androidstats',
    password => 'J4s98AK0w',
    encoding => 'UTF-8',
    grant    => 'ALL'
  }
  dtg::firewall::postgres{'deviceanalyzer':
    source      => $deviceanalyzer_ip,
    source_name => 'deviceanalyzer',
  }

}

if ( $::monitor ) {
  nagios::monitor { 'hound4':
    parents    => '',
    address    => 'hound4.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
#  nagios::monitor { 'deviceanalyzer-database':
#    parents    => 'nas04',
#    address    => 'deviceanalyzer-database.dtg.cl.cam.ac.uk',
#    hostgroups => [ 'ssh-servers' ],
#  }
  nagios::monitor { 'deviceanalyzer':
    parents    => ['nas04', 'nas02'],
    address    => 'deviceanalyzer.cl.cam.ac.uk',
    hostgroups => [ 'http-servers', 'ssh-servers', 'https-servers' ],
  }
  nagios::monitor { 'secure.deviceanalyzer':
    parents    => 'deviceanalyzer',
    address    => 'secure.deviceanalyzer.cl.cam.ac.uk',
    hostgroups => [ 'http-servers', 'https-servers' ],
  }
  nagios::monitor { 'upload.deviceanalyzer':
    parents    => 'deviceanalyzer',
    address    => 'upload.deviceanalyzer.cl.cam.ac.uk',
    hostgroups => [ 'http-servers', 'https-servers' ],
  }
  munin::gatherer::configure_node { 'hound4': }
  munin::gatherer::configure_node { 'deviceanalyzer': }
}
