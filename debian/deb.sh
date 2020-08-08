#!/bin/bash


version="6.3.0"
cd debian/
rm -rf builder/

# copy to a tmp directory
mkdir builder
mkdir builder/redmine-plugin-apijs-${version}

cp -r ../src/app    builder/redmine-plugin-apijs-${version}/
cp -r ../src/assets builder/redmine-plugin-apijs-${version}/
cp -r ../src/config builder/redmine-plugin-apijs-${version}/
cp -r ../src/lib    builder/redmine-plugin-apijs-${version}/
cp ../src/init.rb   builder/redmine-plugin-apijs-${version}/
cp ../src/readme    builder/redmine-plugin-apijs-${version}/
cp /usr/share/common-licenses/GPL-2  builder/redmine-plugin-apijs-${version}/LICENSE
sed -i 's/'${version}'/'${version}-deb'/g' builder/redmine-plugin-apijs-${version}/init.rb










cd builder/
tar czf redmine-plugin-apijs-${version}.tar.gz redmine-plugin-apijs-${version}/
cd ..

# create package
cd builder/redmine-plugin-apijs-${version}/
dh_make -s -y -f ../redmine-plugin-apijs-${version}.tar.gz
rm -f debian/*ex debian/*EX debian/README* debian/*doc*
mkdir debian/upstream
cp ../../control   debian/
cp ../../changelog debian/
cp ../../copyright debian/
cp ../../install   debian/
cp ../../watch     debian/
cp ../../rules     debian/
cp ../../lintian   debian/redmine-plugin-apijs.lintian-overrides
cp ../../upstream  debian/upstream/metadata
dpkg-buildpackage -us -uc
cd ..
debsign redmine-plugin-apijs_${version}-*.changes
cd ..

# cleanup
rm -rf builder/redmine-plugin-apijs-${version}/ builder/redmine-plugin-apijs-${version}.tar.gz