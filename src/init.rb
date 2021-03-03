# encoding: utf-8
# Created L/21/05/2012
# Updated S/12/12/2020
#
# Copyright 2008-2021 | Fabrice Creuzot (luigifab) <code~luigifab~fr>
# https://www.luigifab.fr/redmine/apijs
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
require 'apijs_const'
require 'apijs_files'
require 'apijs_attachment'
require 'useragentparser'

Redmine::Plugin.register :redmine_apijs do

  name 'Redmine Apijs plugin'
  author 'Fabrice Creuzot'
  description 'Integrate the apijs javascript library into Redmine.'
  version '6.6.0'
  url 'https://www.luigifab.fr/redmine/apijs'
  author_url 'https://www.luigifab.fr/'

  permission :edit_attachments, {apijs: :edit}, {require: :loggedin}
  permission :rename_attachments, {apijs: :rename}, {require: :loggedin}
  permission :delete_attachments, {apijs: :delete}, {require: :loggedin}
  requires_redmine version_or_higher: '1.4.0'

  settings({
    partial: 'settings/apijs',
    default: {
      enabled: '0',
      sort_attachments: '0',
      browser: '0',
      show_album: '0',
      show_album_infos: '0',
      show_filename: '0',
      show_exifdate: '0',
      album_exclude_name: '',
      album_exclude_desc: '',
      create_all: '0',
      # python-pil
      album_mimetype_jpg: '1',
      album_mimetype_jpeg: '1',
      album_mimetype_gif: '0',
      album_mimetype_png: '0',
      album_mimetype_tif: '0',
      album_mimetype_tiff: '0',
      album_mimetype_webp: '0',
      album_mimetype_bmp: '0',
      album_mimetype_eps: '0',
      album_mimetype_psd: '0',
      # python-scour
      album_mimetype_svg: '1',
      # ffmpegthumbnailer
      album_mimetype_ogv: '1',
      album_mimetype_webm: '1',
      album_mimetype_mp4: '0'
    }
  })
end