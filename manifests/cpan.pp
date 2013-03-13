# Class: perl::cpan
#
# This class configures cpan.
# It's automatically required by perl::module define
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
    timeout => 600,
  }

  exec{ 'install_cpanminus':
    path    => ['/usr/bin/','/bin'],
    command => 'cpan -i App::cpanminus',
    unless  => 'perldoc -l App::cpanminus',
    timeout => 600,
    require => Exec['configure_cpan'],
  }

}
