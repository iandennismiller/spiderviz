#!/bin/bash

port_path=`which port`
apt_path=`which apt-get`
cpan_path=`which cpan`
dot_path='which dot'

perl_yaml=`perl -MYAML -e 1 2>&1`
perl_lwp=`perl -MLWP -e 1 2>&1`
perl_sleepy=`perl -MWWW::Mechanize::Sleepy -e 1 2>&1`
perl_base64=`perl -MMIME::Base64 -e 1 2>&1`

function install_graphviz {
    if [ -n "$port_path" ]; then
        echo "running 'port install graphviz'"
        port install graphviz
    else
        if [ -n "$apt_path" ]; then
            echo "running 'apt-get install graphviz'"
            apt-get install graphviz
        else
            echo "NOTICE: you must install graphviz manually"
            echo "see http://www.graphviz.org/Download.php"
        fi
    fi    
}

function install_cpan {
    if [ -n "$cpan_path" ]; then
        echo "running 'cpan -i YAML LWP WWW::Mechanize::Sleepy MIME::Base64'"
        cpan -i YAML LWP WWW::Mechanize::Sleepy MIME::Base64
    else
        echo "NOTICE: you must use CPAN to manually install:"
        echo "YAML LWP WWW::Mechanize::Sleepy MIME::Base64"
    fi
}

function copy_files {
    mkdir -v ~/perl
    mkdir -v ~/bin
    
    install -v bin/spiderviz.pl ~/bin
    cp -v lib/spiderviz.pm ~/perl
    cp -v etc/spiderviz.yaml ~/.spiderviz.yaml
}

function display_usage {
    cat doc/README.txt
}

function main {
    if [ -z "$dot_path" ]; then
        install_graphviz
    else
        echo "skipping graphviz install"
    fi
    
    if [ -n "$perl_yaml" -o -n "$perl_sleepy" -o -n "$perl_base64" -o -n "$perl_lwp" ]; then
        install_cpan        
    else
        echo "skipping perl modules install"
    fi

    copy_files

    #display_usage
}

main
