package Apache::Clean;

#---------------------------------------------------------------------
# usage: PerlHandler Apache::Clean
#
#        PerlSetVar Filter On       # optional - will work within 
#                                   # Apache::Filter
#
#        PerlSetVar CleanLevel  N   # 1 to 9 - see HTML::Clean manpage
#                                   # defaults to 3
#
#---------------------------------------------------------------------

use 5.004;
use mod_perl 1.21;
use Apache::Constants qw( OK DECLINED );
use Apache::File;
use Apache::Log;
use HTML::Clean;
use strict;

$Apache::Clean::VERSION = '0.01';

# set debug level
#  0 - messages at info or debug log levels
#  1 - verbose output at info or debug log levels
$Apache::Clean::DEBUG = 0;

sub handler {
#---------------------------------------------------------------------
# initialize request object and variables
#---------------------------------------------------------------------
  
  my $r            = shift;

  my $log          = $r->server->log;

  my $filter       = $r->dir_config('Filter') || undef;

  my $level        = $r->dir_config('CleanLevel')  || 3;

  my ($fh, $status);

  # make Apache::Filter aware
  if (lc($filter) eq 'on') {
    $r->server->log->info("\tregistering handler with Apache::Filter")
       if $Apache::Clean::DEBUG;
    $r = $r->filter_register;
  }

#---------------------------------------------------------------------
# do some preliminary stuff...
#---------------------------------------------------------------------

  $log->info("Using Apache::Clean");

  unless ($r->content_type eq 'text/html') {
    $log->info("\trequest is not for an html document - skipping...")
       if $Apache::Clean::DEBUG;
    $log->info("Exiting Apache::Clean");  
    return DECLINED; 
  }

#---------------------------------------------------------------------
# get the filehandle
#---------------------------------------------------------------------

  if ($filter) {
    $log->info("\tgetting request input from Apache::Filter")
       if $Apache::Clean::DEBUG;
    ($fh, $status) = $r->filter_input;
    undef $fh unless $status == OK
  } else {
    $log->info("\tgetting request input from Apache::File")
       if $Apache::Clean::DEBUG;
    $fh = Apache::File->new($r->filename);
  }

  unless ($fh) {
    $log->warn("\tcannot open request! $!");
    $log->info("Exiting Apache::Clean");
    return DECLINED;
  }

#---------------------------------------------------------------------
# clean up the html
#---------------------------------------------------------------------

   local $/;
   my $dirty       = <$fh>;
   my $h           = HTML::Clean->new(\$dirty);

   $h->level($level);
   $h->strip;

   my $clean       = $h->data();

#---------------------------------------------------------------------
# print the clean results
#---------------------------------------------------------------------
  
  $r->send_http_header('text/html');

  $r->print($$clean);

#---------------------------------------------------------------------
# wrap up...
#---------------------------------------------------------------------

  $log->info("Exiting Apache::Clean");

  return OK;
}

1;
 
__END__

=head1 NAME 

Apache::Clean - mod_perl interface into HTML::Clean

=head1 SYNOPSIS

httpd.conf:

 <Location /someplace>
    SetHandler perl-script
    PerlHandler Apache::Clean

    PerlSetVar  CleanLevel 3
 </Location>  

Apache::Clean is Filter aware, meaning that it can be used within
Apache::Filter framework without modification.  Just include the
directives

  PerlModule Apache::Filter
  PerlSetVar Filter On

and modify the PerlHandler directive accordingly...

=head1 DESCRIPTION

Apache::Clean uses HTML::Clean to tidy up large, messy HTML, saving
bandwidth.  It is particularly useful with Apache::Compress for 
ultimate savings.

The only current configuration directive is CleanLevel, which defaults
to 3.  Apache::Clean will only tidy up whitespace (via $h->strip) and
will not perform other options of HTML::Clean (such as browser
compatibility).  See the HTML::Clean manpage for details.

Only documents with a content type of "text/html" are affected - all
others are passed through unaltered.

=head1 NOTES

Verbose debugging is enabled by setting $Apache::Clean::DEBUG=1
or greater.  To turn off all debug information, set your apache
LogLevel directive above info level.

This is alpha software, and as such has not been tested on multiple
platforms or environments.  It requires PERL_LOG_API=1, 
PERL_FILE_API=1, and maybe other hooks to function properly.

=head1 FEATURES/BUGS

  No unknown bugs or features at this time...

=head1 SEE ALSO

perl(1), mod_perl(3), Apache(3), Apache::Filter(3), 
Apache::Compress(3), HTML::Clean(3)

=head1 AUTHOR

Geoffrey Young <geoff@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2001, Geoffrey Young.  All rights reserved.

This module is free software.  It may be used, redistributed
and/or modified under the same terms as Perl itself.

=cut
