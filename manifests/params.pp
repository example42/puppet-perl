# Class: perl::params
#
# This class defines default parameters used by the main module class perl
# Operating Systems differences in names and paths are addressed here
#
# == Variables
#
# Refer to perl class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It may be imported or inherited by other classes
#
class perl::params {

  ### Application related parameters
  $cpan_mirror = 'http://www.perl.com/CPAN/'
  $package_prefix = 'perl-'

  $package = $::operatingsystem ? {
    default => 'perl',
  }

  # General Settings
  $my_class = ''
  $version = 'present'
  $absent = false
  $noops = false

}
