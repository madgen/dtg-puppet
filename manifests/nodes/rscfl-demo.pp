node 'rscfl-demo.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'

  class { 'dtg::firewall::publichttp': }
  ->
  class { 'dtg::firewall::80to8080': }
}

if ( $::monitor ) {
  nagios::monitor { 'rscfl-demo':
    parents    => 'nas04',
    address    => 'rscfl-demo.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  munin::gatherer::configure_node { 'rscfl-demo': }
}
