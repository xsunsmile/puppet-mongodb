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

class mongodb::ruby {
	package{ "ruby": ensure => installed }
	package{ "mongo": ensure => installed, provider => 'gem' }
	package{ "bson_ext": ensure => installed, provider => 'gem' }
	package{ "SystemTimer": ensure => installed, provider => 'gem' }
}
