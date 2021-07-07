#!/bin/bash
# openSUSE: sudo zypper install rpmdevtools rpmlint rpm-build redmine aspell-fr


cd "$(dirname "$0")"
version="6.7.0"


rm -rf builder/ ~/rpmbuild/
mkdir -p builder ~/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}

# copy to a tmp directory
if [ true ]; then
	chmod 644 redmine-apijs.spec
	spectool -g -R redmine-apijs.spec
else
	temp=redmine-apijs-$version
	mkdir /tmp/$temp
	cp -r ../* /tmp/$temp/
	rm -rf /tmp/$temp/*/builder/

	mv /tmp/$temp builder/
	cp /usr/share/licenses/kernel-firmware/GPL-2 builder/$temp/LICENSE

	cd builder/
	tar czf $temp.tar.gz $temp
	cd ..

	cp builder/$temp.tar.gz ~/rpmbuild/SOURCES/redmine-apijs-$version.tar.gz
	chmod 644 redmine-apijs.spec
fi

# create package (rpm sign https://access.redhat.com/articles/3359321)
rpmbuild -ba redmine-apijs.spec
rpm --addsign ~/rpmbuild/RPMS/*/*.rpm
rpm --addsign ~/rpmbuild/SRPMS/*.rpm
mv ~/rpmbuild/RPMS/*/*.rpm builder/
mv ~/rpmbuild/SRPMS/*.rpm builder/
echo "==========================="
rpm --checksig builder/*.rpm
echo "==========================="
rpmlint redmine-apijs.spec builder/*.rpm
echo "==========================="
ls -dltrh builder/*.rpm
echo "==========================="

# cleanup
rm -rf builder/*/ ~/rpmbuild/