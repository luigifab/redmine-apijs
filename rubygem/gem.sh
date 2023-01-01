#!/bin/bash
# Debian: sudo apt install ruby


cd "$(dirname "$0")"
version="6.9.3"
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
cp redmine_apijs.gemspec builder/redmine_apijs-${version}/
cp redmine_apijs.rb      builder/redmine_apijs-${version}/lib/
cp /usr/share/common-licenses/GPL-2 builder/redmine_apijs-${version}/LICENSE
sed -i 's/'${version}'/'${version}-gem'/g' builder/redmine_apijs-${version}/init.rb
sed -i 's/x.y.z/'${version}'/g' builder/redmine_apijs-${version}/redmine_apijs.gemspec
find builder/redmine_apijs-${version}/ -type f | xargs chmod +r






# create package (https://guides.rubygems.org/make-your-own-gem/)
cd builder/redmine_apijs-${version}/
gem build redmine_apijs.gemspec
cd ../..
mv builder/redmine_apijs-${version}/*.gem .
echo "==========================="
ls -dlth $PWD/*.gem
echo "==========================="

# cleanup
rm -r builder/