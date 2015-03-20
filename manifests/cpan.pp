# Class: perl::cpan
#
# This class configures cpan.
#
class perl::cpan (
  $exec_path = '/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin:/usr/local/sbin',
  $exec_environment = [ 'HOME=/root' ],
) inherits perl {

  if $perl::cpan_package != '' and ! defined(Package[$perl::cpan_package]) {
    package { $perl::cpan_package:
      ensure  => $perl::manage_cpan_package,
    }
  }

  exec{ 'configure_cpan':
    command => "cpan <<EOF
yes
yes
no
no
${perl::cpan_mirror}

yes
quit
EOF",
    creates => '/root/.cpan/CPAN/MyConfig.pm',
    require => [ Package[$perl::cpan_package] ],
    user    => root,
    path    => $exec_path,
    timeout => 600,
    environment => $exec_environment,
  }

}
