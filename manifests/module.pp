# Define: perl::module
#
# Installs the defined perl module
#
# Variables:
# [*use_package*]
#   (default=false) - Tries to install perl module with the relevant OS package
#   If set to "no" it installs the module via a cpanm command
#
# Usage:
# include perl 
# perl::module { packagename: }
#
# Example:
# perl::module { 'Net::SSLeay': }
#
define perl::module (
  $no_test             = false,
  $use_package         = false,
  $package_name        = 'package_default',
  $package_prefix      = $::perl::package_prefix,
  $package_suffix      = $::perl::package_suffix,
  $package_downcase    = $::perl::package_downcase,

  $url                 = 'url_default',
  $exec_path           = '/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin:/usr/local/sbin',
  $exec_environment    = [],
  $exec_timeout        = '600',

  $ensure              = 'present'
  ) {

  include ::perl

  $pkg_name = $package_downcase ? {
    true  => downcase(regsubst($name,'::','-','G')),
    false => regsubst($name,'::','-','G'),
  }

  $real_package_name = $package_name ? {
    'package_default' => "${package_prefix}${pkg_name}${package_suffix}",
    default           => $package_name,
  }

  $bool_use_package = any2bool($use_package)

  $install_name = $url ? {
    'url_default' => $name,
    default       => $url,
  }

  $cpan_opts = $no_test ? {
    true  => "--notest",
    false => "",
  } 

  $cpan_command = $ensure ? {
    'present' => "cpanm ${cpan_opts} ${install_name}",
    'absent'  => "pm-uninstall -f ${name}",
  }

  $cpan_command_check = $ensure ? {
    'present' => "perldoc -l ${name}",
    'absent'  => "perldoc -l ${name} || true",
  }

  case $bool_use_package {
    true: {
      package { "perl-${name}":
        ensure => $ensure,
        name   => $real_package_name,
      }
    }
    default: {
      exec { "ensure-cpanminus-${name}":
        path        => $exec_path,
        command     => 'curl -L http://cpanmin.us | perl - App::cpanminus',
        unless      => 'perldoc -l App::cpanminus',
        timeout     => $exec_timeout,
        environment => $exec_environment,
        require     => $::perl::cpanminus_require,
      } -> exec { "cpan-${name}-${ensure}":
        command     => $cpan_command,
        unless      => $cpan_command_check,
        path        => $exec_path,
        environment => $exec_environment,
        timeout     => $exec_timeout,
        require     => $::perl::cpanminus_require,
      }
    }
  }
}
