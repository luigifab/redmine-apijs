#!/bin/bash
# openSUSE: sudo zypper install rpmdevtools rpm-build redmine aspell-fr


cd "$(dirname "$0")"
version="6.9.7"


mkdir -p builder ~/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
find builder/* ! -name "*$version*.rpm" ! -name "*$version*.gz" -exec rm -rf {} + 2>/dev/null

# copy to a tmp directory
if [ true ]; then
	chmod 644 redmine-plugin-apijs.spec
	spectool -g -R redmine-plugin-apijs.spec
else
	temp=redmine-apijs-$version
	mkdir /tmp/$temp
	cp -r ../../* /tmp/$temp/
	rm -rf /tmp/$temp/scripts/*/builder/

	mv /tmp/$temp builder/
	cp /usr/share/licenses/*-firmware/GPL-2 builder/$temp/LICENSE # * = kernel

	cd builder/
	tar czf $temp.tar.gz $temp
	cd ..

	cp builder/$temp.tar.gz ~/rpmbuild/SOURCES/redmine-apijs-$version.tar.gz
	chmod 644 redmine-plugin-apijs.spec
fi

# create package (rpm sign https://access.redhat.com/articles/3359321)
rpmbuild -ba redmine-plugin-apijs.spec
rpm --addsign ~/rpmbuild/RPMS/*/redmine-plugin-apijs*.rpm
rpm --addsign ~/rpmbuild/SRPMS/redmine-plugin-apijs*.rpm
mv ~/rpmbuild/RPMS/*/redmine-plugin-apijs*.rpm builder/
mv ~/rpmbuild/SRPMS/redmine-plugin-apijs*.rpm builder/
echo "==========================="
rpm --checksig builder/*.rpm
echo "==========================="
rpmlint redmine-plugin-apijs.spec builder/*.rpm
echo "==========================="
ls -dlth "$PWD/"builder/*.rpm
echo "==========================="

# cleanup
rm -rf builder/*/