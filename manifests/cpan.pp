# Class: perl::cpan
#
# This class configures cpan.
#
class perl::cpan inherits perl {

  exec{ 'configure_cpan':
    command => "/usr/bin/cpan <<EOF
yes
yes
no
no
${perl::cpan_mirror}

yes
quit
EOF",
    creates => '/root/.cpan/CPAN/MyConfig.pm',
    require => Package[$perl::package],
    user    => root,
    timeout => 600,
  }

}
