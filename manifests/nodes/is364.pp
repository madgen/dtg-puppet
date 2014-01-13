
node "is364-scratch.dtg.cl.cam.ac.uk" {
  include 'dtg::minimal'
  dtg::add_user { 'is364':
    real_name => 'Ian Sheret',
    groups    => ['adm'],
    keys      => [],
    uid       => 3179,
  }
}
if ( $::monitor ) {
  nagios::monitor { 'is364-scratch':
    parents    => '',
    address    => 'is364-scratch.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  munin::gatherer::configure_node { 'is364': }
}
