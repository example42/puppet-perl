# = Class: perl
#
# This is the main perl class
#
#
# == Parameters
#
# [*package_prefix*]
#  Prefix in the name of perl modules, when installed via OS packages
#
# [*package_suffix*]
#  Suffix in the name of perl modules, when installed via OS packages
#
#
# Standard class parameters
# Define the general class behaviour and customizations
#
# [*my_class*]
#   Name of a custom class to autoload to manage module's customizations
#   If defined, perl class will automatically "include $my_class"
#   Can be defined also by the (top scope) variable $perl_myclass
#
# [*version*]
#   The package version, used in the ensure parameter of package type.
#   Default: present. Can be 'latest' or a specific version number.
#   Note that if the argument absent (see below) is set to true, the
#   package is removed, whatever the value of version parameter.
#
# [*absent*]
#   Set to 'true' to remove package(s) installed by module
#   Can be defined also by the (top scope) variable $perl_absent
#
# Default class params - As defined in perl::params.
# Note that these variables are mostly defined and used in the module itself,
# overriding the default values might not affected all the involved components.
# Set and override them only if you know what you're doing.
# Note also that you can't override/set them via top scope variables.
#
# [*package*]
#   The name of perl package
#
# == Examples
#
# You can use this class in 2 ways:
# - Set variables (at top scope level on in a ENC) and "include perl"
# - Call perl as a parametrized class
#
# See README for details.
#
#
class perl (
  $cpan_mirror          = params_lookup( 'cpan_mirror' ),
  $package_prefix       = params_lookup( 'package_prefix' ),
  $package_suffix       = params_lookup( 'package_suffix' ),
  $my_class             = params_lookup( 'my_class' ),
  $version              = params_lookup( 'version' ),
  $absent               = params_lookup( 'absent' ),
  $package              = params_lookup( 'package' ),
  $doc_package          = params_lookup( 'doc_package' ),
  $doc_version          = params_lookup( 'doc_version' ),
  $cpan_package         = params_lookup( 'cpan_package' ),
  $cpan_version         = params_lookup( 'cpan_version' ),
  $module_hash          = params_lookup( 'module_hash' ),
  $cpan_module_hash     = params_lookup( 'cpan_module_hash' )
  ) inherits perl::params {

  $bool_absent=any2bool($absent)

  ### Definition of some variables used in the module
  $manage_package = $perl::bool_absent ? {
    true  => 'absent',
    false => $perl::version,
  }

  $manage_doc_package = $perl::bool_absent ? {
    true  => 'absent',
    false => $perl::doc_version,
  }

  $manage_cpan_package = $perl::bool_absent ? {
    true  => 'absent',
    false => $perl::cpan_version,
  }

  $cpan_require = Exec['configure_cpan']

  $cpanminus_require = $doc_package ? {
    ''      => Package[$perl::package],
    default => Package[$perl::doc_package],
  }

  ### Managed resources
  ### Managed resources
  if ! defined(Package[$perl::package]) {
    package { $perl::package:
      ensure  => $perl::manage_package,
    }
  }

  if $doc_package != '' and ! defined(Package[$perl::doc_package]) {
    package { $perl::doc_package:
      ensure  => $perl::manage_doc_package,
    }
  }

  ### Include custom class if $my_class is set
  if $perl::my_class {
    include $perl::my_class
  }

  ### Integration with Hiera
  if $module_hash != {} {
    validate_hash($module_hash)
    create_resources('perl::module', $module_hash)
  }

  if $cpan_module_hash != {} {
    validate_hash($cpan_module_hash)
    create_resources('perl::cpan::module', $cpan_module_hash)
  }

}
