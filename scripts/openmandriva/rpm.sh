#!/bin/bash
# openSUSE: sudo zypper install rpmdevtools rpm-build redmine aspell-fr abb


cd "$(dirname "$0")"
version="6.9.7"


mkdir -p builder builder/{BUILD,RPMS,SRPMS}
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
	cp /usr/share/common-licenses/GPL*2 builder/$temp/LICENSE

	cd builder/
	tar czf $temp.tar.gz $temp
	cd ..

	mv builder/$temp.tar.gz redmine-apijs-$version.tar.gz
	chmod 644 redmine-plugin-apijs.spec
fi

# create package (rpm sign https://access.redhat.com/articles/3359321)
cp -a redmine-plugin-apijs-$version.tar.gz redmine-plugin-apijs.spec builder/
cd builder/
abb builda
rpm --addsign RPMS/*/redmine-plugin-apijs*.rpm
rpm --addsign SRPMS/redmine-plugin-apijs*.rpm
mv RPMS/*/redmine-plugin-apijs*.rpm .
mv SRPMS/redmine-plugin-apijs*.rpm .
echo "==========================="
rpm --checksig *.rpm
echo "==========================="
rpmlint redmine-plugin-apijs.spec *.rpm
echo "==========================="
ls -dlth "$PWD/"*.rpm
echo "==========================="
cd ..

# cleanup
rm -rf builder/*/ builder/*buildlog builder/*spec