# Class: mongodb::params
#
# This class manages MongoDB parameters
#
# Parameters:
# - The 10gen Ubuntu $repository to use
#
# Sample Usage:
#  include mongodb::params
#
class mongodb::params {

	$mongodb_version = ""

	case $operatingsystemrelease {
		"10.04": {
			$repository="deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen"
		}
		"10.10": {
			$repository="deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen"
		}
	}
}
