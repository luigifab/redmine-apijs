#!/bin/bash


version="6.3.0"
cd rubygem/
rm -rf builder/

# copy to a tmp directory
mkdir builder
mkdir builder/redmine_apijs-${version}

cp -r ../src/app    builder/redmine_apijs-${version}/
cp -r ../src/assets builder/redmine_apijs-${version}/
cp -r ../src/config builder/redmine_apijs-${version}/
cp -r ../src/lib    builder/redmine_apijs-${version}/
cp ../src/init.rb   builder/redmine_apijs-${version}/
cp ../src/readme    builder/redmine_apijs-${version}/README
cp Gemfile          builder/redmine_apijs-${version}/
cp redmine_apijs.gemspec  builder/redmine_apijs-${version}/
cp /usr/share/common-licenses/GPL-2  builder/redmine_apijs-${version}/LICENSE
sed -i 's/'${version}'/'${version}-gem'/g' builder/redmine_apijs-${version}/init.rb
find builder/redmine_apijs-${version}/ -type f | xargs chmod +r











# create package
cd builder/redmine_apijs-${version}/
gem build redmine_apijs.gemspec
cd ../..

# cleanup
mv builder/redmine_apijs-${version}/*.gem .
rm -r builder/