package Apache::Clean;

use Apache::Filter ();      # for filtering
use Apache::RequestRec ();  # for $r->content_type
use Apache::RequestUtil (); # for $r->dir_config 
use Apache::Response ();    # for $r->update_mtime
use Apache::ServerUtil ();  # for Apache->server_root_relative
use APR::Table ();          # for $r->dir_config->get
use Apache::Log ();         # for $r->server->log;

use Apache::Const -compile => qw(OK DECLINED);

use HTML::Clean;
use File::Spec;
use strict;

$Apache::Clean::VERSION = '2.00b';

# Get the package modification time for later update_mtime() calls
(my $package = __PACKAGE__) =~ s!::!/!g;
my $package_mtime = (stat $INC{"$package.pm"})[9];

sub handler {

  my $filter = shift;

  my $r      = $filter->r;

  my $log    = $r->server->log;

  $log->info('Using Apache::Clean to clean up ', $r->uri);

  unless ($r->content_type =~ m!text/html!i) {
    $log->info('skipping request to', $r->uri,
               ' (not an HTML document)' );

    $log->info('Exiting Apache::Clean');

    return Apache::DECLINED;
  }

  # parse the configuration options
  my $level = $r->dir_config->get('CleanLevel') || 1;

  $log->info("Using CleanLevel $level");

  my %options = map { $_ => 1 } $r->dir_config->get('CleanOption');

  $log->info('Found CleanOption ', join " : ", keys %options)
    if %options;
    
  # update only the package modification time for now - 
  # I need to investigate per-server cleanups in 2.0 more

  # a few notes about caching headers...
  #   - the file mtime itself is handled by core Apache
  #   - this all needs to happen _before_ we start interacting
  #     with the filter
  
  $log->debug("updating headers with package mtime $package_mtime...");
  $r->update_mtime($package_mtime);
  $r->set_last_modified;

  # now we can filter the content
  while ($filter->read(my $buffer, 1024)) {

    $log->debug('filtering packet...');

    my $h = HTML::Clean->new(\$buffer);

    $h->level($level);

    $h->strip(\%options);

    $filter->print(${$h->data});
  }

  $log->info('Exiting Apache::Clean');

  return Apache::OK;
}

1;
 
__END__

=head1 NAME 

Apache::Clean - mod_perl interface into HTML::Clean

=head1 SYNOPSIS

httpd.conf:

 PerlModule Apache::Clean

 <Location /clean>
    PerlOutputFilterHandler Apache::Clean

    PerlSetVar  CleanLevel 3

    PerlSetVar  CleanOption shortertags
    PerlAddVar  CleanOption whitespace
 </Location>  

=head1 DESCRIPTION

Apache::Clean uses HTML::Clean to tidy up large, messy HTML, saving
bandwidth.  It is particularly useful with Apache::Compress for 
ultimate savings.

Only documents with a content type of "text/html" are affected - all
others are passed through unaltered.

Apache::Clean also tries to be intelligent about setting proper
caching headers.  For the moment, it only considers the modification
time of itself in the header calculations.  Future versions may
consider things like httpd.conf and .htaccess files.  Note that
the core Apache content handler takes care of updating cache headers
for static files - if you are using a dynamic content handler you
need to do that one yourself.

=head1 OPTIONS

Apache::Clean supports few options - all of which are based on
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

=back

=head1 NOTES

This is alpha software, and as such has not been tested on multiple
platforms or environments.

=head1 FEATURES/BUGS

probably lots - this is the preliminary port to mod_perl 2.0

=head1 SEE ALSO

perl(1), mod_perl(3), Apache(3), HTML::Clean(3)

=head1 AUTHORS

Geoffrey Young <geoff@modperlcookbook.org>

=head1 COPYRIGHT

Copyright (c) 2002, Geoffrey Young
All rights reserved.

This module is free software.  It may be used, redistributed
and/or modified under the same terms as Perl itself.

=head1 HISTORY

This code is derived from the Cookbook::Clean and
Cookbook::TestMe modules available as part of
"The mod_perl Developer's Cookbook".

For more information, visit http://www.modperlcookbook.org/

=cut
