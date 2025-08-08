%define basedir /srv/redmine/
%define plugin_name redmine_apijs

Name:          redmine-plugin-apijs
Version:       6.9.8
Release:       0
Summary:       Plugin for Redmine to display a gallery from attachments
Summary(fr):   Extension pour Redmine pour afficher une galerie à partir des pièces jointes
License:       GPL-2.0-or-later and MIT and OFL-1.1
URL:           https://github.com/luigifab/redmine-apijs
Source0:       %{url}/archive/v%{version}/%{name}-%{version}.tar.gz

BuildArch:     noarch
BuildRequires: redmine
BuildRequires: aspell-fr
Requires:      %{python_module pil}
Requires:      %{python_module scour}
Requires:      perl(Image::ExifTool)
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
* Fri Aug 08 2025 Fabrice Creuzot <code@luigifab.fr> - 6.9.8-1
- New upstream release

* Fri Apr 04 2025 Fabrice Creuzot <code@luigifab.fr> - 6.9.7-1
- New upstream release

* Mon Jan 01 2024 Fabrice Creuzot <code@luigifab.fr> - 6.9.6-1
- New upstream release

* Tue Oct 10 2023 Fabrice Creuzot <code@luigifab.fr> - 6.9.5-1
- New upstream release

* Tue Jun 06 2023 Fabrice Creuzot <code@luigifab.fr> - 6.9.4-1
- New upstream release

* Sun Jan 01 2023 Fabrice Creuzot <code@luigifab.fr> - 6.9.3-1
- New upstream release

* Mon Oct 10 2022 Fabrice Creuzot <code@luigifab.fr> - 6.9.2-1
- New upstream release

* Mon Aug 08 2022 Fabrice Creuzot <code@luigifab.fr> - 6.9.1-1
- New upstream release

* Thu Jul 07 2022 Fabrice Creuzot <code@luigifab.fr> - 6.9.0-1
- New upstream release

* Sat Jan 01 2022 Fabrice Creuzot <code@luigifab.fr> - 6.8.2-1
- New upstream release

* Sun Oct 10 2021 Fabrice Creuzot <code@luigifab.fr> - 6.8.1-1
- New upstream release

* Sun Aug 08 2021 Fabrice Creuzot <code@luigifab.fr> - 6.8.0-1
- New upstream release

* Wed Jul 07 2021 Fabrice Creuzot <code@luigifab.fr> - 6.7.0-1
- New upstream release

* Wed Mar 03 2021 Fabrice Creuzot <code@luigifab.fr> - 6.6.0-1
- Initial openSUSE package release
