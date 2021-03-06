node 'dhcp.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'

  class { 'network::interfaces':
    interfaces => {
      'eth0' => {
        'method'          => 'static',
        'address'         => '128.232.20.36',
        'netmask'         => '255.255.252.0',
        'gateway'         => '128.232.20.1',
        'dns-nameservers' => $::dns_name_servers,
      }
    },
    auto       => ['eth0'],
  }

  class { 'dhcp':
   dnsdomain    => [
                     $org_domain,
                    '128.232.20.in-addr.arpa',
                    ],
    nameservers => $name_servers,
    ntpservers  => $ntp_servers,
    interfaces  => ['eth0'],

  }

  dhcp::pool{ 'dtg.cl.cam.ac.uk':
    network    => '128.232.20.0',
    mask       => '255.255.252.0',
    range      => ['128.232.20.8', '128.232.22.255'],
    # gateway should be route.cl
    gateway    => '128.232.20.1',
    parameters => 'deny unknown-clients',
  }
  dhcp::host {
    'rscfl-vguest-0':mac => '00:16:3F:00:00:00', ip => '128.232.22.50';
    'rscfl-vguest-1':mac => '00:16:3F:00:00:01', ip => '128.232.22.51';
    'rscfl-vguest-2':mac => '00:16:3F:00:00:02', ip => '128.232.22.52';
    'rscfl-vguest-3':mac => '00:16:3F:00:00:03', ip => '128.232.22.53';
    'rscfl-vguest-4':mac => '00:16:3F:00:00:04', ip => '128.232.22.54';
    'rscfl-vguest-5':mac => '00:16:3F:00:00:05', ip => '128.232.22.55';
    'rscfl-vguest-6':mac => '00:16:3F:00:00:06', ip => '128.232.22.56';
    'rscfl-vguest-7':mac => '00:16:3F:00:00:07', ip => '128.232.22.57';
    'rscfl-vguest-8':mac => '00:16:3F:00:00:08', ip => '128.232.22.58';
    'rscfl-vguest-9':mac => '00:16:3F:00:00:09', ip => '128.232.22.59';
    'rscfl-vguest-10':mac => '00:16:3F:00:00:10', ip => '128.232.22.60';
    'rscfl-vguest-11':mac => '00:16:3F:00:00:11', ip => '128.232.22.61';
    'rscfl-vguest-12':mac => '00:16:3F:00:00:12', ip => '128.232.22.62';
    'rscfl-vguest-13':mac => '00:16:3F:00:00:13', ip => '128.232.22.63';
    'rscfl-vguest-14':mac => '00:16:3F:00:00:14', ip => '128.232.22.64';
    'rscfl-vguest-15':mac => '00:16:3F:00:00:15', ip => '128.232.22.65';
    'rscfl-vguest-16':mac => '00:16:3F:00:00:16', ip => '128.232.22.66';

    'rscfl-vguest-s-0':mac => '00:16:3F:00:00:17', ip => '128.232.22.67';
    'rscfl-vguest-s-1':mac => '00:16:3F:00:00:18', ip => '128.232.22.68';
    'rscfl-vguest-s-2':mac => '00:16:3F:00:00:19', ip => '128.232.22.69';
    'rscfl-vguest-s-3':mac => '00:16:3F:00:00:20', ip => '128.232.22.70';
    'rscfl-vguest-s-4':mac => '00:16:3F:00:00:21', ip => '128.232.22.71';
    'rscfl-vguest-s-5':mac => '00:16:3F:00:00:22', ip => '128.232.22.72';
    'rscfl-vguest-s-6':mac => '00:16:3F:00:00:23', ip => '128.232.22.73';
    'rscfl-vguest-s-7':mac => '00:16:3F:00:00:24', ip => '128.232.22.74';
    'rscfl-vguest-s-8':mac => '00:16:3F:00:00:25', ip => '128.232.22.75';
    'rscfl-vguest-s-9':mac => '00:16:3F:00:00:26', ip => '128.232.22.76';
    'rscfl-vguest-s-10':mac => '00:16:3F:00:00:27', ip => '128.232.22.77';
    'rscfl-vguest-s-11':mac => '00:16:3F:00:00:28', ip => '128.232.22.78';
    'rscfl-vguest-s-12':mac => '00:16:3F:00:00:29', ip => '128.232.22.79';
    'rscfl-vguest-s-13':mac => '00:16:3F:00:00:30', ip => '128.232.22.80';
    'rscfl-vguest-s-14':mac => '00:16:3F:00:00:31', ip => '128.232.22.81';
    'rscfl-vguest-s-15':mac => '00:16:3F:00:00:32', ip => '128.232.22.82';
    'rscfl-vguest-s-16':mac => '00:16:3F:00:00:33', ip => '128.232.22.83';

    'rscfl-wguest-0':mac => '00:16:3F:00:01:00', ip => '128.232.22.100';

    'saluki1-nic3':mac => '00:1e:67:ba:ba:13', ip =>'128.232.22.49';
    'rscfl-10g-0':mac => '00:0f:53:16:0f:ec', ip => '128.232.22.18';
    'wolf1-10g':mac => '00:0f:53:08:da:bd', ip => '128.232.22.20';
    'wolf2-10g':mac => '00:0f:53:08:cf:c4', ip => '128.232.22.19';

    'wolf0':mac => '00:1e:67:59:8b:6f', ip => '128.232.22.8';
    'wolf1':mac => '00:1e:67:51:c4:03', ip => '128.232.22.10';
    'wolf2':mac => '00:1e:67:b6:52:7f', ip => '128.232.22.11';
    'collar0':mac => '00:80:a3:a3:10:b3', ip => '128.232.22.128';
    'collar1':mac => '00:80:a3:a3:10:c9', ip => '128.232.22.129';
    'inuit':mac => '00:92:58:00:53:c3', ip => '128.232.20.17';
    'spaniel':mac => 'b8:27:eb:bc:d7:cb', ip => '128.232.20.96';
    'fluffy':mac => '00:04:4b:26:fa:34', ip => '128.232.20.97';
    'puppy0':mac => '00:16:3E:E8:14:1C', ip => '128.232.20.28';
    'puppy1':mac => '00:16:3E:E8:14:1D', ip => '128.232.20.29';
    'puppy2':mac => '00:16:3E:E8:14:1E', ip => '128.232.20.30';
    'puppy3':mac => '00:16:3E:E8:14:1F', ip => '128.232.20.31';
    'puppy4':mac => '00:16:3E:E8:14:20', ip => '128.232.20.32';
    'puppy5':mac => '00:16:3E:E8:14:21', ip => '128.232.20.33';
    'puppy6':mac => '00:16:3E:E8:14:22', ip => '128.232.20.34';
    'puppy7':mac => '00:16:3E:E8:14:23', ip => '128.232.20.35';
    'puppy8':mac => '00:16:3E:E8:14:24', ip => '128.232.20.36';
    'puppy9':mac => '00:16:3E:E8:14:25', ip => '128.232.20.37';
    'puppy10':mac => '00:16:3E:E8:14:26', ip => '128.232.20.38';
    'puppy11':mac => '00:16:3E:E8:14:27', ip => '128.232.20.39';
    'puppy12':mac => '00:16:3E:E8:14:28', ip => '128.232.20.40';
    'puppy13':mac => '00:16:3E:E8:14:29', ip => '128.232.20.41';
    'puppy14':mac => '00:16:3E:E8:14:2A', ip => '128.232.20.42';
    'puppy15':mac => '00:16:3E:E8:14:2B', ip => '128.232.20.43';
    'puppy16':mac => '00:16:3E:E8:14:2C', ip => '128.232.20.44';
    'puppy17':mac => '00:16:3E:E8:14:2D', ip => '128.232.20.45';
    'puppy18':mac => '00:16:3E:E8:14:2E', ip => '128.232.20.46';
    'puppy19':mac => '00:16:3E:E8:14:2F', ip => '128.232.20.47';
    'puppy20':mac => '00:16:3E:E8:14:30', ip => '128.232.20.48';
    'puppy21':mac => '00:16:3E:E8:14:31', ip => '128.232.20.49';
    'puppy22':mac => '00:16:3E:E8:14:32', ip => '128.232.20.50';
    'puppy23':mac => '00:16:3E:E8:14:33', ip => '128.232.20.51';
    'puppy24':mac => '00:16:3E:E8:14:34', ip => '128.232.20.52';
    'puppy25':mac => '00:16:3E:E8:14:35', ip => '128.232.20.53';
    'puppy26':mac => '00:16:3E:E8:14:36', ip => '128.232.20.54';
    'puppy27':mac => '00:16:3E:E8:14:37', ip => '128.232.20.55';
    'puppy28':mac => '00:16:3E:E8:14:38', ip => '128.232.20.56';
    'puppy29':mac => '00:16:3E:E8:14:39', ip => '128.232.20.57';
    'puppy30':mac => '00:16:3E:E8:14:40', ip => '128.232.20.58';
    'puppy31':mac => '00:16:3E:E8:14:41', ip => '128.232.20.59';
    'puppy32':mac => '00:16:3E:E8:14:43', ip => '128.232.20.61'; # One ip address skipped
    'puppy33':mac => '00:16:3E:E8:14:44', ip => '128.232.20.62';
    'puppy34':mac => '00:16:3E:E8:14:45', ip => '128.232.20.63';
    'puppy35':mac => '00:16:3E:E8:14:46', ip => '128.232.20.64';
    'puppy36':mac => '00:16:3E:E8:14:47', ip => '128.232.20.65';
    'puppy37':mac => '00:16:3E:E8:14:48', ip => '128.232.20.66';
    'puppy38':mac => '00:16:3E:E8:14:49', ip => '128.232.20.67';
    'puppy39':mac => '00:16:3E:E8:14:4A', ip => '128.232.20.68';
    'puppy40':mac => '00:16:3E:E8:14:4B', ip => '128.232.20.69';
    'puppy41':mac => '00:16:3E:E8:14:4C', ip => '128.232.20.70';
    'puppy42':mac => '00:16:3E:E8:14:4D', ip => '128.232.20.71';
    'puppy43':mac => '00:16:3E:E8:14:4E', ip => '128.232.20.72';
    'puppy44':mac => '00:16:3E:E8:14:4F', ip => '128.232.20.73';
    'puppy45':mac => '00:16:3E:E8:14:50', ip => '128.232.20.74';
    'puppy46':mac => '00:16:3E:E8:14:51', ip => '128.232.20.75';
    'puppy47':mac => '00:16:3E:E8:14:52', ip => '128.232.20.76';
    'puppy48':mac => '00:16:3E:E8:14:53', ip => '128.232.20.77';
    'puppy49':mac => '00:16:3E:E8:14:54', ip => '128.232.20.78';
    'puppy50':mac => '00:16:3E:E8:14:55', ip => '128.232.20.79';
    'puppy51':mac => '00:16:3E:E8:14:56', ip => '128.232.20.80'; #isaac tickets
    'puppy52':mac => '00:16:3E:E8:14:57', ip => '128.232.20.81'; #isaac editor
    'puppy53':mac => '00:16:3E:E8:14:58', ip => '128.232.20.82'; #isaac reserved
    'puppy54':mac => '00:16:3E:E8:14:59', ip => '128.232.20.83'; #isaac reserved
    'puppy55':mac => '00:16:3E:E8:14:5A', ip => '128.232.20.84'; #isaac dev
    'puppy56':mac => '00:16:3E:E8:14:5B', ip => '128.232.20.85'; #isaac staging
    'puppy57':mac => '00:16:3E:E8:14:5C', ip => '128.232.20.86'; #isaac live
    'puppy58':mac => '00:16:3E:E8:14:5D', ip => '128.232.20.87'; #isaac york staging
    'puppy59':mac => '00:16:3E:E8:14:5E', ip => '128.232.20.88';
    'puppy60':mac => '00:16:3E:E8:14:5F', ip => '128.232.20.89';
    'puppy61':mac => '00:16:3E:E8:14:60', ip => '128.232.20.90';
    'puppy62':mac => '00:16:3E:E8:14:61', ip => '128.232.20.91';
    'puppy63':mac => '00:16:3E:E8:14:62', ip => '128.232.20.92';
    # Skip a bit. RT #94175
    'puppy64':mac => '00:16:3E:E8:14:80', ip => '128.232.20.128';
    'puppy65':mac => '00:16:3E:E8:14:81', ip => '128.232.20.129';
    'puppy66':mac => '00:16:3E:E8:14:82', ip => '128.232.20.130';
    'puppy67':mac => '00:16:3E:E8:14:83', ip => '128.232.20.131';
    'puppy68':mac => '00:16:3E:E8:14:84', ip => '128.232.20.132';
    'puppy69':mac => '00:16:3E:E8:14:85', ip => '128.232.20.133';
    'puppy70':mac => '00:16:3E:E8:14:86', ip => '128.232.20.134';
    'puppy71':mac => '00:16:3E:E8:14:87', ip => '128.232.20.135';
    'puppy72':mac => '00:16:3E:E8:14:88', ip => '128.232.20.136';
    'puppy73':mac => '00:16:3E:E8:14:89', ip => '128.232.20.137';
    'puppy74':mac => '00:16:3E:E8:14:8A', ip => '128.232.20.138';
    'puppy75':mac => '00:16:3E:E8:14:8B', ip => '128.232.20.139';
    'puppy76':mac => '00:16:3E:E8:14:8C', ip => '128.232.20.140';
    'puppy77':mac => '00:16:3E:E8:14:8D', ip => '128.232.20.141';
    'puppy78':mac => '00:16:3E:E8:14:8E', ip => '128.232.20.142';
    'puppy79':mac => '00:16:3E:E8:14:8F', ip => '128.232.20.143';
    'puppy80':mac => '00:16:3E:E8:14:90', ip => '128.232.20.144';
    'puppy81':mac => '00:16:3E:E8:14:91', ip => '128.232.20.145';
    'puppy82':mac => '00:16:3E:E8:14:92', ip => '128.232.20.146';
    'puppy83':mac => '00:16:3E:E8:14:93', ip => '128.232.20.147';
    'puppy84':mac => '00:16:3E:E8:14:94', ip => '128.232.20.148';
    'puppy85':mac => '00:16:3E:E8:14:95', ip => '128.232.20.149';
    'puppy86':mac => '00:16:3E:E8:14:96', ip => '128.232.20.150';
    'puppy87':mac => '00:16:3E:E8:14:97', ip => '128.232.20.151';
    'puppy88':mac => '00:16:3E:E8:14:98', ip => '128.232.20.152';
    'puppy89':mac => '00:16:3E:E8:14:99', ip => '128.232.20.153';
    'puppy90':mac => '00:16:3E:E8:14:9A', ip => '128.232.20.154';
    'puppy91':mac => '00:16:3E:E8:14:9B', ip => '128.232.20.155';
    'puppy92':mac => '00:16:3E:E8:14:9C', ip => '128.232.20.156';
    'puppy93':mac => '00:16:3E:E8:14:9D', ip => '128.232.20.157';
    'puppy94':mac => '00:16:3E:E8:14:9E', ip => '128.232.20.158';
    'puppy95':mac => '00:16:3E:E8:14:9F', ip => '128.232.20.159';
    'deviceanalyzer-database':mac => '00:0E:0C:BC:0E:E4', ip => '128.232.23.47';
  }
}

if ( $::monitor ) {
  nagios::monitor { 'dhcp':
    parents    => 'nas04',
    address    => 'dhcp.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  munin::gatherer::configure_node { 'dhcp': }
}
