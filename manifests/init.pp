# Class: mongodb
#
# This class installs MongoDB (stable)
#
# Notes:
#  This class is Ubuntu specific.
#  By Sean Porter, Gastown Labs Inc.
#
# Actions:
#  - Install MongoDB using a 10gen Ubuntu repository
#  - Manage the MongoDB service
#  - MongoDB can be part of a replica set
#
# Sample Usage:
#  include mongodb
#
$mongo_host = $user_mongo_host ?{
	'' => "127.0.0.1",
	default => $mongo_host,
}

class mongodb {

	include mongodb::params
	include mongodb::ruby
	
	$mongodb_version = $mongodb::params::mongodb_version

	package { "python-software-properties":
		ensure => installed,
	}
	
	# exec { "10gen-apt-repo":
	# 	path => "/bin:/usr/bin",
	# 	command => "add-apt-repository '${mongodb::params::repository}'",
	# 	unless => "cat /etc/apt/sources.list | grep 10gen",
	# 	require => Package["python-software-properties"],
	# }
	# 
	# exec { "10gen-apt-key":
	# 	path => "/bin:/usr/bin",
	# 	command => "apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10",
	# 	unless => "apt-key list | grep 10gen",
	# 	require => Exec["10gen-apt-repo"],
	# }

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
		cwd => "/tmp/mongodb:/usr/bin:/usr/local/bin",
		path => "/tmp/mongodb",
		command => "fetch.sh",
		require => File['/tmp/mongodb/fetch.sh'],
	}

	file { "/tmp/mongodb/mongodb.deb":
		ensure => present,
		owner => root,
		group => root,
		require => Exec['fetch-deb'],
	}

	exec { "install-mongodb-manually":
		command => "sudo dpkg -i /tmp/mongodb/mongodb.deb",
		unless => "dpkg -s mongodb 2>/dev/null",
		require => File["/tmp/mongodb/mongodb.deb"],
	}
	
	service { "mongodb":
		enable => true,
		ensure => running,
		require => Exec["install-mongodb-manually"],
	}

	file { '/usr/bin/mongo_get':
		mode => "755",
		owner => root,
		group => root,
		content => template("mongodb/mongo_get.sh.erb"),
	}

	$command_puthost = $hostname_s ?{
		'' => "mongo_host put",
		default => "mongo_host put ${hostname_s}",
	}

	exec { "add_host":
		path => "/bin:/usr/bin",
		command => $command_puthost,
		require => [ Service['mongodb'], File['/usr/bin/mongo_host'] ],
	}

	define replica_set {
		file { "/etc/init/mongodb.conf":
			content => template("mongodb/mongodb.conf.erb"),
			mode => "0644",
			notify => Service["mongodb"],
		}
	}

	define mongofile_put {
		exec { "mongofile_put_${name}":
			command => "mongofiles -r --host ${MONGO_HOST} put ${name}",
			require => Service["mongodb"],
		}
	}

	define mongofile_get {
		exec { "mongofile_get_${name}":
			command => "mongo_get ${MONGO_HOST} ${name} && echo ''",
			require => [ File['/usr/bin/mongo_get'], Service["mongodb"] ],
		}
	}

}

