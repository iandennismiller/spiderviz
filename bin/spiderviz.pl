#!/usr/bin/env perl

use lib "$ENV{HOME}/perl";
use spiderviz;

sub main
{
	my $spiderviz = spiderviz->new();
	$spiderviz->load_config($ARGV[0]);
	$spiderviz->run();
}

&main;
