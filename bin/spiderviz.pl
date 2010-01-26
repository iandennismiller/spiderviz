#!/usr/bin/env perl

use lib "$ENV{HOME}/perl";
use spiderviz;

sub main
{
    print <<EOF
Usage:
spiderviz.pl site.yaml > site.dot
dot -Tpdf -osite.pdf site.dot
(or, instead of dot: neato, twopi, circo)

EOF
    
	my $spiderviz = spiderviz->new();
	$spiderviz->load_config($ARGV[0]);
	$spiderviz->run();
}

&main;
