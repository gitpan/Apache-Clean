#!perl

use ExtUtils::MakeMaker;
use Apache2;

WriteMakefile(
    'NAME'         => 'Apache::Clean',
    'VERSION_FROM' => 'Clean.pm',
    'PREREQ_PM'    => { HTML::Clean    => 0.08,
                        mod_perl       => 1.99 },
);

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
