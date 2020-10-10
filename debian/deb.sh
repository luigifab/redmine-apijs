#!/bin/bash
# debian: sudo apt install dpkg-dev devscripts dh-make



cd "$(dirname "$0")"
version="6.4.0"


rm -rf builder/
mkdir builder

# copy to a tmp directory
if [ true ]; then
	cd builder
	wget https://github.com/luigifab/redmine-apijs/archive/v${version}/redmine-apijs-${version}.tar.gz
	tar xzf redmine-apijs-${version}.tar.gz
	cd ..
else
	temp=redmine-apijs-${version}
	mkdir /tmp/${temp}
	cp -r ../* /tmp/${temp}/
	rm -rf /tmp/${temp}/*/builder/

	mv /tmp/${temp} builder/
	cp /usr/share/common-licenses/GPL-2 builder/${temp}/LICENSE

	cd builder/
	tar czf ${temp}.tar.gz ${temp}
	cd ..
fi


# create packages for debian and ubuntu
for serie in unstable hirsute groovy focal bionic xenial trusty precise; do

	if [ $serie = "unstable" ]; then
		# for ubuntu
		cp -a builder/redmine-apijs-${version}/ builder/redmine-apijs-${version}+src/
		# debian only
		cd builder/redmine-apijs-${version}/
	else
		# ubuntu only
		cp -a builder/redmine-apijs-${version}+src/ builder/redmine-apijs+${serie}-${version}/
		cd builder/redmine-apijs+${serie}-${version}/
	fi

	dh_make -a -s -y -f ../redmine-apijs-${version}.tar.gz -p redmine-plugin-apijs

	rm -f debian/*ex debian/*EX debian/README* debian/*doc*
	mkdir debian/upstream
	mv debian/metadata debian/upstream/metadata
	mv debian/lintian  debian/redmine-plugin-apijs.lintian-overrides



	if [ $serie = "unstable" ]; then
		dpkg-buildpackage -us -uc
	else
		# debhelper: unstable:13 hirsute:13 groovy:13 focal:12 bionic:9 xenial:9 trusty:9 precise:9
		if [ $serie = "focal" ]; then
			sed -i 's/debhelper-compat (= 13)/debhelper-compat (= 12)/g' debian/control
		fi
		if [ $serie = "bionic" ]; then
			sed -i 's/debhelper-compat (= 13)/debhelper-compat (= 9)/g' debian/control
		fi
		if [ $serie = "xenial" ]; then
			sed -i 's/debhelper-compat (= 13)/debhelper (>= 9)/g' debian/control
			sed -i ':a;N;$!ba;s/Rules-Requires-Root: no\n//g' debian/control
			echo 9 > debian/compat
		fi
		if [ $serie = "trusty" ]; then
			sed -i 's/debhelper-compat (= 13)/debhelper (>= 9)/g' debian/control
			sed -i ':a;N;$!ba;s/Rules-Requires-Root: no\n//g' debian/control
			echo 9 > debian/compat
		fi
		if [ $serie = "precise" ]; then
			sed -i 's/debhelper-compat (= 13)/debhelper (>= 9)/g' debian/control
			sed -i ':a;N;$!ba;s/Rules-Requires-Root: no\n//g' debian/control
			echo 9 > debian/compat
		fi
		sed -i 's/unstable/'${serie}'/g' debian/changelog
		sed -i 's/-5) /-5+'${serie}') /' debian/changelog
		dpkg-buildpackage -us -uc -ui -d -S
	fi
	echo "==========================="
	cd ..

	if [ $serie = "unstable" ]; then
		# debian only
		debsign redmine-plugin-apijs_${version}-*.changes
		echo "==========================="
		lintian -EviIL +pedantic redmine-plugin-apijs_${version}-*.deb
	else
		# ubuntu only
		debsign redmine-plugin-apijs_${version}*+${serie}*source.changes
	fi
	echo "==========================="
	cd ..
done

ls -dltrh $PWD/builder/*.deb $PWD/builder/*.changes
echo "==========================="

# cleanup
rm -rf builder/*/