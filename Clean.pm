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

$Apache::Clean::VERSION = '0.03';

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

  my $fh           = undef;

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

  if (lc $r->dir_config('Filter') eq 'on') {

    $log->info("\tgetting request input from Apache::Filter")
       if $Apache::Clean::DEBUG;

    # Register ourselves with Apache::Filter so
    # later filters can see our output.
    $r = $r->filter_register;

    # Get any output from previous filters in the chain.
    ($fh, my $status) = $r->filter_input;

    unless ($status == OK) {
      $log->warn("\tApache::Filter returned $status");
      $log->info("Exiting Apache::Clean");
  
      return $status;
    }
  }
  else {

    $log->info("\tgetting request input from Apache::File")
       if $Apache::Clean::DEBUG;

    # We are not part of a filter chain, so just process as normal.
    $fh = Apache::File->new($r->filename);

    unless ($fh) {
      $log->warn("\tcannot open request! $!");
      $log->info("Exiting Apache::Clean");
  
      return DECLINED;
    }
  }

#---------------------------------------------------------------------
# clean up the html
#---------------------------------------------------------------------

  # Slurp the file.
  my $dirty = do {local $/; <$fh>};

  # Create the new HTML::Clean object.
  my $h = HTML::Clean->new(\$dirty);

  # Set the level of suds.
  $h->level($r->dir_config('CleanLevel') || 1);

  my %options = map { $_ => 1 } $r->dir_config->get('CleanOption');

  # clean the HTML
  $h->strip(\%options);

#---------------------------------------------------------------------
# print the clean results
#---------------------------------------------------------------------

  # Send the crisp, clean data.
  $r->send_http_header('text/html');
  print ${$h->data};

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

 <Location /clean>
    SetHandler perl-script
    PerlHandler Apache::Clean

    PerlSetVar  CleanLevel 3

    PerlSetVar  CleanOption shortertags
    PerlAddVar  CleanOption whitespace
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

  No known bugs or features at this time...

=head1 SEE ALSO

perl(1), mod_perl(3), Apache(3), HTML::Clean(3), Apache::Compress(3),
Apache::Filter(3)

=head1 AUTHORS

Geoffrey Young <geoff@modperlcookbook.org>
Paul Lindner <paul@modperlcookbook.org>
Randy Kobes <randy@modperlcookbook.org>

=head1 COPYRIGHT

Copyright (c) 2002, Geoffrey Young, Paul Lindner, Randy Kobes.  
All rights reserved.

This module is free software.  It may be used, redistributed
and/or modified under the same terms as Perl itself.

=head1 HISTORY

This code is derived from the Cookbook::Clean and
Cookbook::TestMe modules available as part of
"The mod_perl Developer's Cookbook".

For more information, visit http://www.modperlcookbook.org/

=cut
