class dtg::git {
  # Setup gitolite package
  $gitolitepackages = ['gitolite']
  package {$gitolitepackages :
    ensure => installed,
  }
  group {'git': ensure => present,}
  user {'git':
    ensure  => present,
    home    => '/srv/git/',
    gid     => 'git',
    comment => 'Git Version Control',
    shell   => '/bin/bash',
  }
  file {'/local/data/git':
    ensure => directory,
    owner  => 'git',
    group  => 'git',
    mode   => '2755',
  }
  file {'/srv/git/':
    ensure => link,
    target => '/local/data/git/',
  }
  #TODO(drt24) setup backups and restore from backups
  # Setup gitlab
  $gitlabpackages = ['ruby1.9.1', 'ruby1.9.1-dev', 'rubygems1.9.1', 'ruby-bundler', 'python-pygments', 'libicu-dev', 'libmysqlclient-dev', 'ruby-sqlite3', 'libsqlite3-dev', 'libxslt-dev','libxml2-dev', 'libcurl4-openssl-dev', 'libreadline6-dev', 'libssl-dev', 'libmysql++-dev', 'redis-server', 'python-dev', 'libyaml-dev']
  package {$gitlabpackages :
    ensure => installed,
  }
  package {['ruby','rubygems']:
    ensure => 'purged',# these point at old 1.8 ruby
  }
  group {'gitlab': ensure => 'present',}
  user {'gitlab':
    ensure   => 'present',
    gid      => 'gitlab',
    groups   => 'git',
    comment  => 'Gitlab System',
    home     => '/srv/gitlab/',
    password => '!',#disable login
  }
  file {'/local/data/gitlab':
    ensure => directory,
    owner  => 'gitlab',
    group  => 'gitlab',
    mode   => '2755',
  }
  file {'/srv/gitlab/':
    ensure => link,
    target => '/local/data/gitlab/',
  }
  file {'/srv/gitlab/.ssh/':
    ensure => directory,
    owner  => 'gitlab',
    group  => 'gitlab',
    mode   => '0700',
  }
  exec {'gen-gitlab-sshkey':
    command => 'sudo -H -u gitlab -g gitlab ssh-keygen -q -N "" -t rsa -f /srv/gitlab/.ssh/id_rsa',
    creates => '/srv/gitlab/.ssh/id_rsa',
    require => File['/srv/gitlab/.ssh/'],
  }
  # Setup gitolite
  # Bootstrap admin key
#  file {'/srv/git/drt24.pub':
#    ensure => file,
#    source => 'puppet:///modules/dtg/ssh/drt24.pub',
#  }
  file {'/srv/git/gitlab.pub':
    ensure  => file,
    source  => 'file:///srv/gitlab/.ssh/id_rsa.pub',
    owner   => 'gitlab',
    group   => 'git',
    mode    => '0744',
    require => Exec['gen-gitlab-sshkey'],
  }
  file {'/usr/share/gitolite/conf/example.gitolite.rc':
    ensure => file,
    source => 'puppet:///modules/dtg/example.gitolite.rc',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    require => Package['gitolite'],
  }
  exec {'setup-gitolite':
    command => 'sudo -H -u git -g git gl-setup gitlab.pub',
    cwd     => '/srv/git/',
    creates => '/srv/git/repositories/',
    require => File['/srv/git/gitlab.pub', '/usr/share/gitolite/conf/example.gitolite.rc'],
  }
  # Install gitlab
  package {'charlock_holmes':
    ensure   => 'latest',
    provider => 'gem',
    require  => Package['rubygems'],
  }
  vcsrepo {'/srv/gitlab/gitlab/':
    ensure   => latest,
    provider => 'git',
    source   => 'git://github.com/gitlabhq/gitlabhq.git',
    revision => 'stable',
    owner    => 'gitlab',
    group    => 'gitlab',
    require  => File['/srv/gitlab/'],
  }
  file {'/srv/gitlab/gitlab/tmp/':
    ensure => directory,
    owner  => 'gitlab',
    group  => 'gitlab',
    require => Vcsrepo['/srv/gitlab/gitlab/'],
  }
  $gitlab_from_address = $::from_address
  file {'/srv/gitlab/gitlab/config/gitlab.yml':
    ensure  => file,
    content => template('dtg/gitlab/gitlab.yml.erb'),
    require => Vcsrepo['/srv/gitlab/gitlab/'],
  }
  # setup database stuff
  class { 'mysql::server':
    config_hash => { 'root_password' => 'mysql-password' }
  }
  class { 'mysql': }
  class { 'mysql::ruby': }
  $gitlabpassword = "gitlabpassword"#TODO(drt24) generate this automatically without overwriting on every run
  mysql::db { 'gitlabhq_production':
    user     => 'gitlab',
    password => 'gitlab',
    host     => 'localhost',
    grant    => ['all'],
    require  => Class['mysql::server'],
  }
  class { 'mysql::backup':
    backupuser     => 'mysqlbackup',
    backuppassword => 'mysqlbackup',
    backupdir      => '/var/backups/mysql/',
  }
  file {'/srv/gitlab/gitlab/config/database.yml':
    ensure  => file,
    content => template('dtg/gitlab/database.yml.erb'),
    owner   => 'gitlab',
    group   => 'gitlab',
    require => Vcsrepo['/srv/gitlab/gitlab/'],
  }
  exec {'install gitlab bundle':
    command => 'sudo -u gitlab -g gitlab -H bundle install --without development test --deployment',
    unless  => 'false',#TODO(drt24)
    cwd     => '/srv/gitlab/gitlab/',
    require => [File['/srv/gitlab/gitlab/config/gitlab.yml'],Class['mysql::ruby'],Package['libmysqlclient-dev']],
  }
  exec {'setup gitlab database':
    command => 'sudo -u gitlab -g gitlab -H bundle exec rake gitlab:app:setup RAILS_ENV=production',
    unless  => 'false',#TODO(drt24)
    cwd     => '/srv/gitlab/gitlab/',
    require => [File['/srv/gitlab/gitlab/config/database.yml'],Exec['install gitlab bundle']],
  }
  file {'/usr/share/gitolite/hooks/common/post-receive':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'file:///srv/gitlab/gitlab/lib/hooks/post-receive',
    require => [Package['gitolite'],Vcsrepo['/srv/gitlab/gitlab/']],
  }
  exec {'start gitlab':
    command => 'sudo -u gitlab -g gitlab -H bundle exec rails s -e production -d',
    unless  => 'false',#TODO(drt24)
    cwd     => '/srv/gitlab/gitlab/',
    require => Exec['install gitlab bundle','setup gitlab database'],
  }
}
