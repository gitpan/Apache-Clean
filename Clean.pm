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
use Apache;
use Apache::File;
use Apache::Log;
use HTML::Clean;
use strict;

$Apache::Clean::VERSION = '0.04';

# set debug level
#  0 - messages at info or debug log levels
#  1 - verbose output at info or debug log levels
$Apache::Clean::DEBUG = 1;

# Get the package modification time...
(my $package = __PACKAGE__) =~ s!::!/!g;
my $package_mtime = (stat $INC{"$package.pm"})[9];

# ...and when httpd.conf was last modified
my $conf_mtime = (stat Apache->server_root_relative('conf/httpd.conf'))[9];

# When the server is restarted we need to
# make sure we recognize config file changes and propigate
# them to the client to clear the client cache if necessary.
Apache->server->register_cleanup(sub {
  $conf_mtime = (stat Apache->server_root_relative('conf/httpd.conf'))[9];
});

sub handler {
#---------------------------------------------------------------------
# initialize request object and variables
#---------------------------------------------------------------------

  my $r            = shift;

  my $log          = $r->server->log;

  my ($fh, $cache) = ();

#---------------------------------------------------------------------
# do some preliminary stuff...
#---------------------------------------------------------------------

  $log->info("Using Apache::Clean");

  unless ($r->content_type =~ m!text/html!i) {
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

    # since we're essentially sending a static file
    # we can set cache headers properly based on the
    # file itself - although we're modifying the 
    # content the meaning of the content doesn't
    # change unless it:
    #   changes on disk
    #   this package is modified
    #   our httpd.conf options have changed

    # however, in the interests of back compatibility, make
    # proper cache behavior an option
    $cache = lc $r->dir_config('CleanCache') || 'on';

    if ($cache eq 'on') {
      # set what we can from here, more later...
      $r->update_mtime($package_mtime);
      $r->update_mtime((stat $r->finfo)[9]);
      $r->update_mtime($conf_mtime);
      $r->set_last_modified;
      $r->set_etag;
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

  if ($cache eq 'on') {
    # we needed to clean the data first before we
    # could find the length
    $r->set_content_length(length ${$h->data});

    # only send the file if it meets cache criteria
    if ((my $status = $r->meets_conditions) == OK) {
      $r->send_http_header('text/html');
    }
    else {
      return $status;
    }
  }
  else {
    # else we just send a header
    $r->send_http_header('text/html');
  }

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

 PerlModule Apache::Clean

 <Location /clean>
    SetHandler perl-script
    PerlHandler Apache::Clean

    PerlSetVar  CleanLevel 3

    PerlSetVar  CleanOption shortertags
    PerlAddVar  CleanOption whitespace

    PerlSetVar  CleanCache On
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

Only documents with a content type of "text/html" are affected - all
others are passed through unaltered.

=head1 OPTIONS

Apache::Clean supports few options, most of which are based on
options from HTML::Clean.  Apache::Clean will only tidy up whitespace 
(via $h->strip) and will not perform other options of HTML::Clean
(such as browser compatibility).  See the HTML::Clean manpage for 
details.

=over 4

=item CleanLevel

sets the clean level, which is passed to the level() method
in HTML::Clean.

  PerlSetVar CleanLevel 9

CleanLevel defaults to 3.

=item CleanOption

specifies the set of options which are passed to the options()
method in HTML::Clean.

  PerlAddVar CleanOption shortertags
  PerlSetVar CleanOption whitespace

CleanOption has do default.

=item CleanCache

sets the behavior of Apache::Clean in regards to proper
cache header behavior.  this option is only meaningful
when Apache::Clean is _not_ part of an Apache::Filter
chain.

mainly, CleanCache On enables Apache::Clean to
set the Last-Modified, Content-Length, and Etag headers,
as well as allowing it do decide whether a 304 response
is allowed.  See recipe 6.6 in the mod_perl Developer's
Cookbook for a more detailed discussion on handling
conditional and cache-based headers - the code is
practically identical to what you will find there.

The basic idea here is that although Apache::Clean is
dynamically manipulating the content of the requested
resource, the meaning of the document has not changed
just because <strong> was changed to <b>.  If you
disagree with this assessment you can set CleanCache to
Off.

CleanCache defaults to On.

=back

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
