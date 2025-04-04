%define basedir %{_var}/www/redmine/
%define plugin_name redmine_apijs

Name:          redmine-plugin-apijs
Version:       6.9.7
Release:       1
Summary:       Plugin for Redmine to display a gallery from attachments
Summary(fr):   Extension pour Redmine pour afficher une galerie à partir des pièces jointes
License:       GPLv2+ and MIT and OFL-1.1
Group:         Networking/WWW
URL:           https://github.com/luigifab/redmine-apijs
Source0:       %{url}/archive/v%{version}/%{name}-%{version}.tar.gz

BuildArch:     noarch
BuildRequires: redmine
BuildRequires: aspell-fr
Requires:      python%{pyver}dist(pil)
#Requires:     python%{pyver}dist(scour)
Requires:      perl-Image-ExifTool
Requires:      redmine
Recommends:    ffmpegthumbnailer

%description %{expand:
This plugin integrates apijs JavaScript library into Redmine.
For more information about the library, go to luigifab.fr/apijs.

This plugin allows:
  * to sort out attachments in alphabetical order
  * to display a photo/video gallery from attachments
  * to display videos in streaming (HTTP 206 Partial Content)
  * to keep the animation of GIF/PNG/WEBP images thanks to Pillow
  * to redefine the date of creation of the photos from the EXIF date
  * to modify the description of attachments
  * to rename and remove attachments}

%description -l fr %{expand:
Cette extension intègre la bibliothèque JavaScript apijs sur Redmine.
Pour plus d'information sur la bibliothèque, voir luigifab.fr/apijs.

Cette extension permet :
  * de trier les pièces jointes par ordre alphabétique
  * d'afficher une galerie photo/vidéo à partir des pièces jointes
  * d'afficher les vidéos en streaming (HTTP 206 Partial Content)
  * de conserver l'animation des images GIF/PNG/WEBP grâce à Pillow
  * de redéfinir la date de création des photos à partir de la date EXIF
  * de modifier la description des pièces jointes
  * de renommer et supprimer des pièces jointes}


%prep
%setup -q -n redmine-apijs-%{version}
sed -i "s/ version '[0-9].[0-9].[0-9]/&-rpm/g" src/init.rb

%install
install -dm 755 %{buildroot}%{basedir}/plugins/%{plugin_name}/
cp -a src/*     %{buildroot}%{basedir}/plugins/%{plugin_name}/
chmod -R o=     %{buildroot}%{basedir}/plugins/%{plugin_name}/
chmod +x        %{buildroot}%{basedir}/plugins/%{plugin_name}/lib/*.py

%files
%license LICENSE
%doc README.md
# the entire source code is GPL-2.0-or-later, except lib/useragentparser.rb which is MIT,
# and assets/fonts/apijs/fontello.woff(2) which is OFL-1.1
%attr(-,root,redmine) %{basedir}/plugins/%{plugin_name}/


%changelog
* Fri Apr 04 2025 Fabrice Creuzot <code@luigifab.fr> - 6.9.7-1
- New upstream release

* Mon Mar 03 2025 Fabrice Creuzot <code@luigifab.fr> - 6.9.6-1
- Initial OpenMandriva package release
