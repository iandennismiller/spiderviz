# (c) 2009 Ian Dennis Miller
# spiderviz is a program to map out the URLs of a given website
# and generate a DOT-compatible representation of those links.
# The output is intended to be rendered with graphviz or dot.

package spiderviz;

use strict;

use WWW::Mechanize::Sleepy;
use MIME::Base64 qw(encode_base64);
use Encode qw(encode);
#use Digest::MD5;
use YAML;

sub new
{
	my $self = {};
	
	$self->{hashes} = {};
	
	return bless($self);
}

# given the global config and another site-specific config, compile
# several regexp patterns and load the YAML config.
sub load_config
{
	my ($self, $config_file) = @_;
	
	my $cfg = {%{YAML::LoadFile("$ENV{HOME}/.spiderviz.yaml")}, %{YAML::LoadFile($config_file)}};

	$self->{base} = \@{$cfg->{base}};

	foreach my $skip_pattern (@{$cfg->{skip_patterns}})
	{
		push (@{$self->{skip_patterns}}, eval("return qr|$skip_pattern|"));
	}

	foreach my $ignore_pattern (@{$cfg->{ignore_patterns}})
	{
		push (@{$self->{ignore_patterns}}, eval("return qr|$ignore_pattern|"));
	}
	
	$self->{cfg} = $cfg;
}

# store a record of this visit according to its URI and a hash of
# the content of that page
sub remember_visit
{
	my ($self, $link, $content) = @_;
	
	my $hash = encode_base64(encode("UTF-8", $content));
	
	$self->{hashes}->{$link} = $hash;
}

# return true if this page has already been visited, but it was
# referred to by a different URI
sub is_synonym
{
	my ($self, $link, $content) = @_;
	
	my $hash = encode_base64(encode("UTF-8", $content));
	
	foreach my $key (keys %{$self->{hashes}})
	{
		if ($hash eq $self->{hashes}->{$key})
		{
			if ($link ne $key)
			{
				print "\t\"$link\" -> \"$key\" [style=\"dotted\"];\n";
				
				$self->remember_visit($link, $content);
				
				print STDERR "synonym\t$link is $key\n";
			}
			
			return 1;
		}
	}
	
	return 0;
}

# return true if the link matches the name of one that has already
# been visited.
sub is_visited
{
	my ($self, $link) = @_;
	
	if (exists $self->{hashes}->{$link})
	{
		print STDERR "already visited\t$link\n";
		
		return 1;
	}

	return 0;
}

# return true if the link matches a pattern that does not need to
# be indicated on the graph (e.g. a name=#something)
sub is_ignored
{
	my ($self, $href) = @_;
	
	foreach my $ignore (@{$self->{ignore_patterns}})
	{
		if ($href =~ $ignore)
		{
			print STDERR "ignore\t\t$href\n";
			
			return 1;			
		}
	}

	return 0;
}

# returns true if the URL has one of the base URL strings in it
sub is_onsite
{
	my ($self, $href) = @_;
	
	foreach my $base_url (@{$self->{base}})
	{
		if ($href =~ m|^$base_url|)
		{
			return 1;
		}
	}
	
	return 0;
}

# returns true if the file does not need to be downloaded (e.g. PDF)
sub is_skippable
{
	my ($self, $link) = @_;
	
	foreach my $pattern (@{$self->{skip_patterns}})
	{
		if ($link =~ $pattern)
		{
			print STDERR "skipping\t$link\n";
			
			return 1;
		}
	}
	
	return 0;
}

# returns a link without its trailing slash, if one exists, or
# the original link if there was no trailing slash
sub drop_trailing_slash
{
	my ($link) = @_;

	if ($link =~ m|^(.*)/$|)
	{
		$link=$1;
	}	

	return $link;
}

# retrieve a page and return all of the links on it, if that page
# is not a synonym for another page.
sub get_links_on_page
{
	my ($self, $link) = @_;
	
	my $mech = $self->{mech};
	
	print STDERR "get\t\t$link\n";	
	$mech->get($link);

	if ($mech->success())
	{
		return 0 if ($self->is_synonym($link, $mech->content()));

		$self->remember_visit($link, $mech->content());

		return \@{$mech->links()};
	}
	else
	{
		print "\t\"$link\" -> \"" . $mech->status() . "\";\n";

		$self->remember_visit($link, $mech->content());
		
		return 0;
	}
}

# if a URL includes one of the base url patterns, remove that portion
# of the string so that only the unique part remains
sub remove_base_from_string
{
	my ($self, $string) = @_;
	
	foreach my $base_url (@{$self->{base}})
	{
		if ($string =~ m|$base_url|)
		{
			$string =~ s|$base_url||gs;
		}
	}

	$string =~ s|""|"/"|gs;
	
	return $string;
}

# visit a link, analyze the links on it, and recursively visit
# those links too.  Along the way, print out a DOT graph string
# to indicate which pages are going to be visited.
sub visit_link
{
	my ($self, $link, $depth) = @_;
	
	my $this_page_links = {};

	$link = drop_trailing_slash($link);

	return if $self->is_skippable($link);
	return if $self->is_visited($link);

	my $links = $self->get_links_on_page($link);
	return if (!$links);

	foreach my $to_visit (@$links)
	{
		my $href = $to_visit->url_abs()->abs;		
		$href = drop_trailing_slash($href);

		if (exists $this_page_links->{$href})
		{
			print STDERR "repeat on page\t$href\n";
			next;
		}
		else
		{
			$this_page_links->{$href}++;
		}
		
		if (!$self->is_ignored($href))
		{
			my $color = $self->{cfg}->{depth_factor} * $depth;
			my $out = "\t\"$link\" -> \"$href\" [color=\"0.$color 1.0 0.8\"];\n";
			$out = $self->remove_base_from_string($out);
			print $out;
			
			if ($self->is_onsite($href))
			{
				$self->visit_link($href, $depth+1);
			}	
		}
	}
}

# start the visit_link process with the first base URL
sub run
{
	my ($self) = @_;
	
	$self->{mech} = WWW::Mechanize::Sleepy->new( agent => 'spiderviz 0.1', sleep => '0..2' );

	print $self->{cfg}->{dot_header};
	
	$self->visit_link(@{$self->{base}}[0], 0);

	print "}";
}

1;