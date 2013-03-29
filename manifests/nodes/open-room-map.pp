node /open-room-map(-\d+)?/ {
  include 'dtg::minimal'
  class {'apache': }
  class {'dtg::apache::raven': server_description => 'Open Room Map'} ->
  apache::module {'proxy':} ->
  apache::module {'proxy_http':} ->
  apache::site {'open-room-map':
    source => 'puppet:///modules/dtg/apache/open-room-map.conf',
  }
  
  $servlet_version = "1.0.4"
  $webtree_version = "1.0.12"

  # Install the openroommap servlet code.  This requires tomcat
  class {'dtg::tomcat': version => '7'}
  ->
  dtg::nexus::fetch{"download-servlet":
    artifact_name => "open-room-map",
    artifact_version => $servlet_version,
    artifact_type => "war",
    destination_directory => "/usr/local/share/openroommap-servlet",
    symlink => "/var/lib/tomcat7/webapps/openroommap.war",
  }
  
  # Install the openroommap static web tree.  This is hosted by apache
  file {"/var/www/research/":
    ensure => directory,
    require => Class['apache'],
  }
  ->
  file {'/var/www/research/dtg/':
    ensure => directory
  }
  ->
  dtg::nexus::fetch{"download-webtree":
    artifact_name => "open-room-map-webtree",
    artifact_version => $webtree_version,
    artifact_type => "zip",
    destination_directory => "/usr/local/share/openroommap-webtree",
    action => "unzip",
    symlink => "/var/www/research/dtg/openroommap",
  }
  ->
  dtg::nexus::fetch{"download-tiles":
    artifact_name => "open-room-map-tiles",
    artifact_version => "1.0.0-SNAPSHOT",
    artifact_type => "zip",
    artifact_classifier => "live",
    destination_directory => "/usr/local/share/openroommap-tiles",
    action => "unzip",
    symlink => "/var/www/research/dtg/openroommap/static/tile",
    always_refresh => true
  }
  
  class {'dtg::firewall::publichttp':}

  class { 'postgresql::server': 
    config_hash => { 
      'ip_mask_deny_postgres_user' => '0.0.0.0/0', 
      'ip_mask_allow_all_users' => '127.0.0.1/32', 
      'listen_addresses' => '*', 
      'ipv4acls' => ['hostssl all all 127.0.0.1/32 md5']
    }
  }
  ->
  postgresql::db{'openroommap':
    user => "orm",
    password => "openroommap",
    charset => "UTF-8",
    grant => "ALL"
  }
  ->
  postgresql::database_user{'ormreader':
    password_hash => postgresql_password('ormreader', 'ormreader')
  }
  dtg::nexus::fetch{"download-ormbackup":
    artifact_name => "open-room-map-backup",
    artifact_version => "1.0.0-SNAPSHOT",
    artifact_type => "zip",
    artifact_classifier => "live",
    destination_directory => "/usr/local/share/openroommap-backup",
    action => "unzip"
  }
  exec{"restore-backup":
    command => "psql -U orm -d openroommap -h localhost -f /usr/local/share/openroommap-backup/open-room-map-backup-1.0.0-SNAPSHOT/backup.sql",
    environment => "PGPASSWORD=openroommap",
    path => "/usr/bin",
    unless => 'psql -U orm -h localhost -d openroommap -t -c "select count(*) from room_table"'
  }  
  ->
  postgresql::db{'machineroom':
    user => "machineroom",
    password => "machineroom",
    charset => "UTF-8",
    grant => "ALL"
  }
    
  # python-scipy, python-jinja2 is used by the machineroom site in /var/www/research/dtg/openroommap/machineroom
  # libdbd-pg-perli is used by the inventory site in /var/www/research/dtg/openroommap/inventory
  # libmath-polygon-perl is used by the rooms site /var/www/research/dtg/openroommap/rooms/
  $openroommappackages = ['python-scipy','python-jinja2' ,'libdbd-pg-perl', 'libmath-polygon-perl','python-psycopg2']
  package{$openroommappackages:
    ensure => installed,
  }
  

  class {'dtg::ravencron::client':}
  file {'/etc/apache2/conf/':
    ensure => directory,
    require => Class['apache'],
  }
  file {'/etc/apache2/conf/group-raven':
    ensure => link,
    target => '/home/ravencron/group-raven',
    require => Class['dtg::ravencron::client'],
  }
}
if ( $::fqdn == $::nagios_machine_fqdn ) {
  nagios::monitor { 'open-room-map':
    parents    => '',
    address    => 'open-room-map.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers' ],
  }
}
if ( $::fqdn == $::munin_machine_fqdn ) {
  munin::gatherer::configure_node { 'open-room-map': }
}
