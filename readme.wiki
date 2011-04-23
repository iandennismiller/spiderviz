= Downloading =

You can find the most recent download here:

http://code.google.com/p/spiderviz/downloads/list

The newest version of spiderviz is always available from subversion.  Just
check out a copy like this:

{{{
svn checkout http://spiderviz.googlecode.com/svn/trunk/ spiderviz
}}}

= Installation =

{{{
cd spiderviz
./setup.sh
}}}

Setup will check for dependencies, and if anything is required, it will try
to install them.  You might be required to run setup.sh with root privileges.

{{{
sudo ./setup.sh
}}}

= Manual Install =

{{{
sudo port install graphviz # or apt-get
sudo cpan -i YAML LWP WWW::Mechanize::Sleepy MIME::Base64

mkdir ~/perl
cp lib/spiderviz.pm ~/perl
mkdir ~/bin
cp bin/spiderviz.pl ~/bin
cp etc/spiderviz.yaml ~/.spiderviz.yaml
}}}

= Usage =

If you haven't already installed spiderviz, then make sure to read about that
here: InstallSpiderviz.

First, make a configuration file for the site you will spider.  In this example
it is called "site.yaml".  Put the following lines into the file:

{{{
base:
    - "http://code.google.com/p/spiderviz/"
depth_factor: 1
}}}

Make sure there is a carriage return on the last line, or YAML will choke on
it.

This is roughly equivalent to saying, "find all URLs that are sub-URLs of the
base URL." The depth factor is the maximum number of hops from the main page
that the spider will go.  Start with 1, and work up to more if the site is
complex.

Now, run spiderviz with your new configuration file:

{{{
~/bin/spiderviz.pl site.yaml > site.dot
dot -Tpdf -osite.pdf site.dot
}}}

= ~/.spiderviz.yaml =

Certain global settings are stored in this file, which you can use to store
your customized settings. 

Skip patterns are those URLs that should not be followed at all, perhaps
because they don't contain HTML or perhaps because you aren't interested in
certain files. Skip patterns are regular expressions.  These files will be
noted in the dot output, but they won't be spidered any further.

Ignore patterns are URLs that will not be noted in the dot output, and they
will not be visited.  This is handy for page anchors, which might appear to
be a different URL but are just a different place on a page.

The dot header is the text that will be placed at the top of your dot file.
There is a while world of tweaking possible here.  A sane default is provided
with spiderviz, but there is more information about dot here:

http://www.graphviz.org/doc/info/attrs.html

Here is an example ~/.spiderviz.yaml:

{{{
skip_patterns:
 - '.zip$'
 - '.pdf$'
 - '.ppt$'
 - '.mov$'
 - '/blog/'
 - "/feed$"

ignore_patterns:
 - '^#'
 - '#\w+$'
 - '#$'

dot_header: >
 digraph G {
 rankdir="LR"; 
 mclimit=64.0; 
 concentrate="true";
 center="true"; 
 overlap=false; 
 splines=true; 
 node[height=.5,width=5.0];
}}}
