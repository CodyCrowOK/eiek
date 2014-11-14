#!/bin/sh

CWD=$(pwd);
cp eiek.pl eiek;
install -m 755 eiek /usr/bin;
rm -f $CWD/eiek;
