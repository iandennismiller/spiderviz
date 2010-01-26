#!/bin/bash

port_path=`which port`
apt_path=`which apt-get`
cpan_path=`which cpan`

function install_graphviz {
    if [ -n "$port_path" ]; then
        echo "running 'sudo port install graphviz'"
        sudo port install graphviz
    else
        if [ -n "$apt_path" ]; then
            echo "running 'sudo apt-get install graphviz'"
            sudo apt-get install graphviz
        else
            echo "NOTICE: you must install graphviz manually"
            echo "see http://www.graphviz.org/Download.php"
        fi
    fi    
}

function install_cpan {
    if [ -n "$cpan_path" ]; then
        echo "running 'sudo cpan -i YAML LWP WWW::Mechanize::Sleepy MIME::Base64'"
        sudo cpan -i YAML LWP WWW::Mechanize::Sleepy MIME::Base64
    else
        echo "NOTICE: you must use CPAN to manually install:"
        echo "YAML LWP WWW::Mechanize::Sleepy MIME::Base64"
    fi
}

function copy_files {
    mkdir -v ~/perl
    cp -v lib/spiderviz.pm ~/perl
    mkdir -v ~/bin
    cp -v bin/spiderviz.pl ~/bin
    cp -v etc/spiderviz.yaml ~/.spiderviz.yaml
}

function display_usage {
    cat doc/README.txt
}

function main {
    install_graphviz
    install_cpan
    copy_files
    display_usage
}

main
