#!perl

use ExtUtils::MakeMaker;
use Apache2 ();
use Apache::Build ();
use ModPerl::MM ();

# override the make test target with Apache::Test stuff
sub MY::test {
  if (eval "require Apache::TestMM") {
    Apache::TestMM::filter_args();
    Apache::TestMM::generate_script('t/TEST');
    Apache::TestMM->import(qw(test clean));
    return Apache::TestMM->test;
  }

  # The whitespace in front of @echo MUST be a single tab!
  return <<'EOF';
test::
	@echo This test suite requires Apache::Test
	@echo available from the mod_perl 2.0 sources
	@echo or the httpd-test distribution.
EOF
}

# do special stuff for mod_perl installations 
# that are relative to Apache2

my %apache2 = 
  Apache::Build->build_config->{'MP_INST_APACHE2'}
    ? ( macro => { MOD_INSTALL => ModPerl::MM::mod_install(), }, )
    : ();

*MY::constants = \&ModPerl::MM::MY::constants;
*MY::post_initialize = \&ModPerl::MM::MY::post_initialize;

# finally, write out the Makefile
WriteMakefile(
    'NAME'         => 'Apache::Clean',
    'VERSION_FROM' => 'Clean.pm',
    'PREREQ_PM'    => { HTML::Clean    => 0.08,
                        mod_perl       => 1.99 },
    %apache2,
);
