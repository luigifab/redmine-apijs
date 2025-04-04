#!/bin/bash
# Debian: sudo apt install dpkg-dev devscripts dh-make


cd "$(dirname "$0")"
version="6.9.7"


mkdir builder
rm -rf builder/*

# copy to a tmp directory
if [ true ]; then
	cd builder
	wget https://github.com/luigifab/redmine-apijs/archive/v$version/redmine-apijs-$version.tar.gz
	tar xzf redmine-apijs-$version.tar.gz
	cd ..
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
fi


# create packages for Debian and Ubuntu
for serie in experimental plucky oracular noble jammy focal bionic xenial trusty; do

	printf "\n\n#################################################################### $serie ##\n\n"
	if [ $serie = "experimental" ]; then
		# copy for Ubuntu
		cp -a builder/redmine-apijs-$version/ builder/redmine-apijs-$version+src/
		cd builder/redmine-apijs-$version/
	elif [ $serie = "unstable" ]; then
		rm -rf builder/redmine-apijs-$version/
		cp -a builder/redmine-apijs-$version+src/ builder/redmine-apijs-$version/
		cd builder/redmine-apijs-$version/
	else
		cp -a builder/redmine-apijs-$version+src/ builder/redmine-apijs+$serie-$version/
		cd builder/redmine-apijs+$serie-$version/
	fi

	dh_make -s -y -f ../redmine-apijs-$version.tar.gz -p redmine-plugin-apijs

	rm -rf debian/*/*ex debian/*ex debian/*EX debian/README* debian/*doc*
	cp scripts/debian/* debian/
	rm -f debian/deb.sh
	mv debian/metadata debian/upstream/metadata
	mv debian/lintian  debian/redmine-plugin-apijs.lintian-overrides


	if [ $serie = "experimental" ]; then
		mv debian/control.debian debian/control
		mv debian/changelog.debian debian/changelog
		echo "=========================== buildpackage ($serie) =="
		dpkg-buildpackage -us -uc
	else
		# debhelper: experimental:13 focal/mx19/mx21:12 bionic:9 xenial:9 trusty:9
		if [ $serie = "unstable" ]; then
			mv debian/control.debian debian/control

		elif [ $serie = "mx19" ] || [ $serie = "mx21" ]; then
			mv debian/control.mx debian/control
			sed -i 's/debhelper-compat (= 13)/debhelper-compat (= 12)/g' debian/control
		elif [ $serie = "focal" ]; then
			mv debian/control.ubuntu debian/control
			sed -i 's/debhelper-compat (= 13)/debhelper-compat (= 12)/g' debian/control
		elif [ $serie = "bionic" ]; then
			mv debian/control.ubuntu debian/control

			sed -i 's/debhelper-compat (= 13)/debhelper-compat (= 9)/g' debian/control
		elif [ $serie = "xenial" ]; then
			mv debian/control.ubuntu debian/control

			sed -i 's/debhelper-compat (= 13)/debhelper (>= 9)/g' debian/control
			sed -i ':a;N;$!ba;s/Rules-Requires-Root: no\n//g' debian/control
			echo 9 > debian/compat
		elif [ $serie = "trusty" ]; then
			mv debian/control.ubuntu debian/control


			sed -i 's/debhelper-compat (= 13)/debhelper (>= 9)/g' debian/control
			sed -i ':a;N;$!ba;s/Rules-Requires-Root: no\n//g' debian/control
			echo 9 > debian/compat
		else
			mv debian/control.ubuntu debian/control
		fi
		if [ $serie = "mx23" ] || [ $serie = "mx21" ] || [ $serie = "mx19" ]; then
			mv debian/changelog.mx debian/changelog
			sed -i 's/-1) /-1~'$serie'+1) /' debian/changelog
		elif [ $serie = "unstable" ]; then
			mv debian/changelog.debian debian/changelog
		else
			mv debian/changelog.ubuntu debian/changelog
			sed -i 's/experimental/'$serie'/g' debian/changelog
			sed -i 's/-1) /-1+'$serie') /' debian/changelog
		fi
		rm -f debian/*.mx debian/*.debian
		echo "=========================== buildpackage ($serie) =="
		dpkg-buildpackage -us -uc -ui -d -S
	fi
	echo "=========================== debsign ($serie) =="
	cd ..

	if [ $serie = "experimental" ]; then
		debsign redmine-plugin-apijs_$version*.changes
		echo "=========================== lintian ($serie) =="
		lintian -EviIL +pedantic redmine-plugin-apijs*$version*.deb
	elif [ $serie = "unstable" ]; then
		debsign redmine-plugin-apijs*$version-*_source.changes
	else
		debsign redmine-plugin-apijs*$version*$serie*source.changes
	fi
	cd ..
done

printf "\n\n"
ls -dlth "$PWD/"builder/*.deb "$PWD/"builder/*.changes
printf "\n"
rm -rf builder/*/