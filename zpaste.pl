#!/usr/bin/env perl
use strict;
use warnings;
use Carp;
use LWP::UserAgent ();

my $ua = LWP::UserAgent->new;

my $file = eval { $ARGV[0] };
croak "Missing required argument [file]" unless $file;

my $data;
open (my $fh, '<', $file) or croak "Couldn't open file: $file";

eval {
	{
		local $/;
		$data = <$fh>
	}
	close($fh);
};
croak "Couldn't read file: $@" if $@;

print $ua->post('http://localhost:3000/new', Content=>$data)->content;
