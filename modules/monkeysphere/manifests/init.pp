# This module is distributed under the GNU Affero General Public License:
# 
# Monkeysphere module for puppet
# Copyright (C) 2009-2010 Sarava Group
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

#
# Class for monkeysphere management
#

import "sshd.pp"

class monkeysphere ($keyserver = "pgp.mit.edu" ) {
  # The needed packages
  package { monkeysphere: ensure => installed, }

  file { "monkeysphere_conf":
    path => "/etc/monkeysphere/monkeysphere.conf",
    mode => 644,
    ensure => present,
    require => Package['monkeysphere'],
    content => template("monkeysphere/monkeysphere.conf.erb"),
  }
  file { "monkeysphere_host_conf":
    path => "/etc/monkeysphere/monkeysphere-host.conf",
    mode => 644,
    ensure => present,
    require => Package['monkeysphere'],
    content => template("monkeysphere/monkeysphere-host.conf.erb"),
  }
  file { "monkeysphere_authentication_conf":
    path => "/etc/monkeysphere/monkeysphere-authentication.conf",
    mode => 644,
    ensure => present,
    require => Package['monkeysphere'],
    content => template("monkeysphere/monkeysphere-authentication.conf.erb"),
  }
  file { "ms-subkey-exists":
    path => "/usr/local/sbin/ms-subkey-exists",
    mode => 755,
    ensure => present,
    source => "puppet:///modules/monkeysphere/ms-subkey-exists",
  }
  
}

define monkeysphere::import_key ( $scheme = 'ssh://', $port = '', $path = '/etc/ssh/ssh_host_rsa_key', $hostname = $::fqdn ) {

  # if we're getting a port number, prefix with a colon so it's valid
  $prefixed_port = $port ? {
    '' => '',
    default => ":$port"
  }

  $key = "${scheme}${hostname}${prefixed_port}"

  exec { "monkeysphere-host import-key $path $key":
    alias => "monkeysphere-import-key",
	  require => [ Package["monkeysphere"],  File["monkeysphere_host_conf"] ],
	  unless => "/usr/sbin/monkeysphere-host s | grep $key > /dev/null"
  }
  
}

define monkeysphere::publish_server_keys {
  exec { "monkeysphere-host-publish-keys":
    command => "monkeysphere-host publish-keys",
    environment => "MONKEYSPHERE_PROMPT=false",
	  require => [ Package["monkeysphere"], Exec["monkeysphere-import-key"], File["monkeysphere_host_conf"] ],
  }
}

# add certifiers
define monkeysphere::add_id_certifier( $keyid ) {
  exec { "monkeysphere-authentication add-id-certifier $keyid && monkeysphere-authentication update-users":
	  environment => "MONKEYSPHERE_PROMPT=false",
	  require => [ Package["monkeysphere"], File["monkeysphere_authentication_conf"] ],
	  unless => "/usr/sbin/monkeysphere-authentication list-id-certifiers | grep $keyid > /dev/null"
  }
}

define monkeysphere::authorized_user_ids( $user_ids,  $dest_dir = '/root/.monkeysphere', $dest_file = 'authorized_user_ids', $group = '', $ensure = 'present') {
  $user = $title
  $calculated_group = $group ? {
    '' => $user,
    default => $group
  }

  file {
    $dest_dir:
      owner => $user,
      group => $calculated_group,
      mode => 755,
      ensure => directory,
  }

  file {
    "${dest_dir}/${dest_file}":
      owner => $user,
      group => $calculated_group,
      mode => 644,
      content => template('monkeysphere/authorized_user_ids.erb'),
      ensure => $ensure,
      require => File[$dest_dir] 
  }

  exec { "monkeysphere-authentication update-users $user":
    refreshonly => true,
    require => [ File["monkeysphere_authentication_conf"], Package["monkeysphere"] ],
    subscribe => File["${dest_dir}/${dest_file}"] 
  }
}

# ensure that the user has a gpg key created and it is authentication capable
# in the monkeysphere. This is intended to be the same as generated a
# password-less ssh key. Depends on gpg module and gpg::private_key 
#
define monkeysphere::auth_capable_user ( $passphrase, $pseudo_random = false ) { 

  $user = $title

  # handle auth subkey
  exec { "monkeysphere-gen-subkey-$user":
    command => "printf '$passphrase\n' | monkeysphere gen-subkey",
    require => [ Package["monkeysphere"], Exec["gpg-pem2openpgp-$user" ] ],
    user => $user,
    unless => "/usr/local/sbin/ms-subkey-exists" 
  }

}

# use runit to maintain - FIXME - only works for root user now
# fixme - you must have runit installed
define monkeysphere::ssh_agent( $passphrase, $ensure = 'running' ) {
  # protected directory to store the ssh-agent socket
  file { "/root/.ssh-agent-socket":
    ensure => "directory",
    mode => 700,
  }

  # service directory
  file { "/etc/sv/ssh-agent-root":
    ensure => "directory",
    require => [ Package["runit"], Exec["monkeysphere-gen-subkey-root"] ]
  }
  
  file { "/etc/sv/ssh-agent-root/run":
    ensure => present,
    mode => 755,
    content => template("monkeysphere/ssh-agent-root.erb"),
    owner => "root",
    require => [  File[ "/etc/sv/ssh-agent-root" ] ]
  } 

  exec { "update-service --add /etc/sv/ssh-agent-root":
    creates => "/etc/service/ssh-agent-root",
    require => [ Package["runit"], File["/etc/sv/ssh-agent-root/run"], File["/root/.ssh-agent-socket"] ],
    user => "root"

  }
}