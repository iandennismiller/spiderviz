#!/bin/bash

VERSION="r14"

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
    if [ ! -e ~/.spiderviz.yaml ]; then
        cp -v etc/spiderviz.yaml ~/.spiderviz.yaml
    else
        echo "will not overwrite ~/.spiderviz.yaml"
    fi
}

function make_dist {
    rm -rf build
    mkdir -v build build/bin build/doc build/lib build/etc build/test
    cp -r -v bin/* build/bin
    cp -r -v doc/* build/doc
    cp -r -v lib/* build/lib
    cp -r -v etc/* build/etc
    cp -r -v test/* build/test
    cp -v setup.sh build
    mkdir -v dist
    cp -r build dist/spiderviz-$VERSION
    cd dist
    tar cf spiderviz-$VERSION.tar spiderviz-$VERSION
    gzip spiderviz-$VERSION.tar
    cd ..
    rm -rf dist/spiderviz-$VERSION
    rm -rf build
}

function do_install {
    if [ -z "$dot_path" ]; then
        install_graphviz
    else
        echo "skipping graphviz install (appears to be already installed)"
    fi
    
    if [ -n "$perl_yaml" -o -n "$perl_sleepy" -o -n "$perl_base64" -o -n "$perl_lwp" ]; then
        install_cpan        
    else
        echo "skipping perl modules install (appears to be already installed)"
    fi

    copy_files

    echo
    echo "To learn how to use spiderviz, please see:"
    echo "http://code.google.com/p/spiderviz/wiki/GettingStarted"
}

if [ "$1" = "dist" ]; then
    make_dist
else
    do_install
fi
