node 'gitlab.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
}
if ( $::monitor ) {
  nagios::monitor { 'gitlab':
    parents    => 'nas04',
    address    => 'gitlab.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers'],
  }
  munin::gatherer::configure_node { 'gitlab': }
}
