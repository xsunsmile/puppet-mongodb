# Class: mongodb
#
# This class installs MongoDB (under dev)
#
# Notes:
#  This class is Ubuntu specific.
#  By Sean Porter, Gastown Labs Inc.
#  modified by Hao SUN, NII
#
# Actions:
#  - Install MongoDB using a 10gen Ubuntu repository
#  - Manage the MongoDB service
#  - MongoDB can be part of a replica set
#
# Sample Usage:
#  include mongodb
#
# in your site.pp
# $extlookup_datadir = "/etc/puppet/manifests/extdata"
# $extlookup_precedence = ["%{fqdn}", "domain_%{domain}", "common"]
#
# in your /etc/puppet/manifests/extdata/common.csv:
# mongodb_version,1.8.1
# mongodb_repo,deb http://...
# mongodb_host,192.168.x.x
#

class mongodb {
	
	$mongodb_version = extlookup('mongodb_version')
	$mongodb_repository = extlookup('mongodb_repo')
	$mongodb_host = extlookup('mongodb_host')

	include mongodb::ruby

	file { "/etc/profile.d/mongodb":
		ensure => present,
		owner => root,
		group => root,
		mode => 755,
		content => template('mongodb/mongodb_profiled.conf.erb'),
	}

	file { "/tmp/mongodb":
		ensure => directory,
		owner => root,
		group => root,
		mode => 0755,
	}

	file { "/tmp/mongodb/fetch.sh":
		ensure => present,
		owner => root,
		group => root,
		content => template("mongodb/fetch.sh.erb"),
		mode => 0755,
		require => File['/tmp/mongodb'],
	}

	exec { "fetch-deb":
		cwd => "/tmp/mongodb",
		path => "/tmp/mongodb:/usr/bin:/usr/local/bin:/bin",
		command => "fetch.sh",
		require => File['/tmp/mongodb/fetch.sh'],
		unless => 'ls /tmp/mongodb/mongodb.deb',
	}

	file { "/tmp/mongodb/mongodb.deb":
		ensure => present,
		owner => root,
		group => root,
		require => Exec['fetch-deb'],
	}

	exec { "install-mongodb-manually":
		command => "sudo dpkg -i /tmp/mongodb/mongodb.deb",
		unless => "dpkg -s mongodb-10gen | grep ^Status | grep ok",
		require => File["/tmp/mongodb/mongodb.deb"],
	}
	
	replace { "unbind-127.0.0.1":
		file => "/etc/mongodb.conf",
		pattern => "^\s*bind_ip.*$",
		replacement => "# bind_ip = 127.0.0.1",
		require => Exec['install-mongodb-manually'],
	}

	service { "mongodb":
		enable => true,
		ensure => running,
		require => Replace['unbind-127.0.0.1'],
	}

	define replica_set {
		file { "/etc/init/mongodb.conf":
			content => template("mongodb/mongodb.conf.erb"),
			mode => "0644",
			notify => Service["mongodb"],
		}
	}

}

