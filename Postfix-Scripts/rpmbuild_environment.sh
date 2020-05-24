#!/bin/sh
# rpmuser Build user rpmbuild environment
# Author: Tuomo Soini <http://tis.foobar.fi>
#

# create directories
for i in SOURCES SPECS BUILD SRPMS RPMS/i386 RPMS/i486 RPMS/i586 RPMS/i686 RPMS/athlon RPMS/noarch
do
  mkdir -p $HOME/rpm/$i
done
unset i

# set environment variables
echo "%_topdir $HOME/rpm" >> $HOME/.rpmmacros
# EOF
