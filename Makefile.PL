#!perl

use ExtUtils::MakeMaker;
use Apache2 ();
use Apache::Build ();
use Apache::TestMM qw(test clean);
use ModPerl::MM ();

# configure Apache::Test based on incoming arguments
Apache::TestMM::filter_args();

# provide the Apache::Test harness
Apache::TestMM::generate_script('t/TEST');

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
    'PREREQ_PM'    => { HTML::Clean    => 0.8,
                        mod_perl       => 1.99 },
    %apache2,
);
