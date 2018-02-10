#!/usr/bin/env perl
#
# ZenPaste - A very simple pastebin server
# /new - Takes post data and stores it in file: data/$id using Storable
#        Returns link to file
# /:id - Retrieves paste by id

use strict;
use warnings;
use Mojolicious::Lite;
use Data::Dumper;
use Storable;
use Storable qw(nstore store_fd nstore_fd freeze thaw dclone);
use Sys::Hostname;

use Try::Tiny;

use constant DATA_DIR => 'data/';
use constant BIND_PORT => '3000';
use constant PROTO => 'http://';
use constant SERVER_ADDR => ( $ENV{'ZEN_PASTE_BIND_ADDR'} || PROTO . hostname() . ':' . BIND_PORT || '127.0.0.1:3000');

mkdir DATA_DIR or die "Couldn't create data dir" unless -e DATA_DIR; # Ensure data dir exists
my @tmp;

# load up our existing $files if any
try {
  opendir DIR, DATA_DIR;
  @tmp = grep { $_ !~ /\.|\.\./ } readdir DIR;
  closedir DIR;
}
catch { warn "Cannot opendir: $_" };
my $files = scalar @tmp > 0 ? \@tmp : [];

# Documentation browser under "/perldoc"
plugin 'PODRenderer';

sub say { print @_, "\n" }

sub getLatestFile { scalar @$files > 0 ? $files->[-1] : 0 };

get '/:id' => sub {
  my $c = shift;
  my $id = $c->stash('id');
  my $rendermsg; # A scalar ref containing the string that will be rendered
  try { $rendermsg = retrieve(DATA_DIR . $id) }
  catch { $rendermsg = \"$id doesn't exist." };
  $c->render(text=>$$rendermsg);
};

post '/new' => sub {
  my $c = shift;
  my $data = $c->req->body;
  my $file = getLatestFile()+1;
  push @$files, $file;
  store \$data, DATA_DIR . $file; # Store the file
  $c->render(text=>SERVER_ADDR . '/' . $file); # Return the address of the file
};

app->start;
__DATA__
