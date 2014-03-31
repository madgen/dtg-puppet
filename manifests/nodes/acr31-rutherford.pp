node /acr31-rutherford(-\d+)?/ {
  include 'dtg::minimal'
  
  class {'dtg::tomcat': version => '7'}
  ->
  user { 'tomcat7':
    shell => '/usr/bin/rssh'
  }
  
  class {'dtg::firewall::publichttp':}
  class {'dtg::firewall::80to8080': private => false}

  class { 'postgresql::globals':
    version => '9.1'
  }
  ->
  class { 'postgresql::server': 
    ip_mask_deny_postgres_user => '0.0.0.0/0', 
    ip_mask_allow_all_users => '127.0.0.1/32', 
    listen_addresses => '*', 
    ipv4acls => ['hostssl all all 127.0.0.1/32 md5']
  }
  ->
  postgresql::server::db{'rutherford':
    user => "rutherford",
    password => "rutherford",
    encoding => "UTF-8",
    grant => "ALL"
  }
  ->
  file {'/usr/share/tomcat7/.ssh/authorized_keys':
    ensure => file,
    mode => '0644',        
    content => 'from="*.cl.cam.ac.uk" ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAlQzIFjqes3XB09BAS9+lhZ9QuLRsFzLb3TwQJET/Q6tqotY41FgcquONrrEynTsJR8Rqko47OUH/49vzCuLMvOHBg336UQD954oIUBmyuPBlIaDH3QAGky8dVYnjf+qK6lOedvaUAmeTVgfBbPvHfSRYwlh1yYe+9DckJHsfky2OiDkych9E+XgQ4GipLf8Cw6127eiC3bQOXPYdZh7uKnW6vpnVPFPF5K1dSaUo3GxcpYt3OsT3IqB640m8mgekWtOmCuAP+9IEBFmCozwpqLz+EWv6wtova7tbVCkrU2iJwTbJzOUCvWv5JHYjAi/pWNIsKnWpFF9+m4th26GY4Q== jenkins@dtg-ci.cl.cam.ac.uk',
   }


  firewall { '011 accept all http on 8080':
    proto   => 'tcp',
    dport   => '8080',
    action  => 'accept',
  }

  $packages = ['maven2','openjdk-7-jdk','rssh']
  package{$packages:
    ensure => installed,
  }
  ->
  file_line { 'rssh-allow-sftp':
    line => 'allowsftp',
    path => '/etc/rssh.conf', 
  }
}

if ( $::monitor ) {
  nagios::monitor { 'rutherford':
    parents    => '',
    address    => 'rutherford.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' , 'http-servers' ],
  }
  munin::gatherer::configure_node { 'rutherford': }
}
