use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile(
    'NAME'      => 'Apache::Clean',
    'VERSION_FROM' => 'Clean.pm', # finds $VERSION
    'PREREQ_PM'    => { HTML::Clean => 0.08, 
                        mod_perl    => 1.21, },
);
