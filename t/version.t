#!perl

print "1..3\n";

require 5.005;
print "ok\n";

eval {
  require mod_perl;
  die "\n\n\tWhoops!  Apache::Clean requires mod_perl 1.21,
\tbut you are only running mod_perl $mod_perl::VERSION.
\tPlease upgrade.\n\n"
  if $mod_perl::VERSION < 1.21;
};

die $@ if $@;
print "ok\n";

eval {
  eval { require Apache::Filter; };
  
  exit 0 if $@;
  die "\n\n\tI see you have Apache::Filter installed...
\tIn order to use Apache::Clean with Apache::Filter, you need
\tto upgrade to Apache::Filter 1.013 or better.\n\n"
     if $Apache::Filter::VERSION < 1.013;
};

warn $@ if $@;
print "ok\n";

exit 0;
