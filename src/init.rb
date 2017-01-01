# encoding: utf-8
# Created L/21/05/2012
# Updated J/29/12/2016
#
# Copyright 2008-2017 | Fabrice Creuzot (luigifab) <code~luigifab~info>
# https://redmine.luigifab.info/projects/redmine/wiki/apijs
#
# This program is free software, you can redistribute it or modify
# it under the terms of the GNU General Public License (GPL) as published
# by the free software foundation, either version 2 of the license, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but without any warranty, without even the implied warranty of
# merchantability or fitness for a particular purpose. See the
# GNU General Public License (GPL) for more details.

require 'redmine'
require 'const'
require 'files_hook'
require 'attachment_patch'
require 'zip'

Redmine::Plugin.register :redmine_apijs do
  name 'Redmine Apijs plugin'
  author 'Fabrice Creuzot'
  description 'Integrate the apijs javascript library into Redmine.'
  version '5.3.0'
  url 'https://redmine.luigifab.info/projects/redmine/wiki/apijs'
  author_url 'https://www.luigifab.info/'

  permission :edit_attachments, { :apijs => :edit }, { :require => :loggedin }
  permission :delete_attachments, { :apijs => :delete }, { :require => [:loggedin, :member] }

  settings({
    :partial => 'settings/apijs',
    :default => {
      :enabled => '0',
      :sort_attachments => '0',
      :show_album => '0',
      :show_album_infos => '0',
      :show_filename => '0',
      :show_exifdate => '0',
      :album_mimetype_jpg  => '1',
      :album_mimetype_jpeg => '1',
      :album_mimetype_png  => '0',
      :album_mimetype_ogv  => '1',
      :album_mimetype_webm => '1',
      :album_mimetype_mp4  => '0',
      :album_mimetype_m4v  => '0',
      :album_mimetype_pdf  => '0',
      :album_mimetype_psd  => '0',
      :album_mimetype_eps  => '0',
      :album_mimetype_tiff => '0',
      :album_exclude_name  => '',
      :album_exclude_desc  => '',
      :create_all => '0'
    }
  })
end