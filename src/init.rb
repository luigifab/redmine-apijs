# encoding: utf-8
# Created L/21/05/2012
# Updated L/24/04/2023
#
# Copyright 2008-2024 | Fabrice Creuzot (luigifab) <code~luigifab~fr>
# https://github.com/luigifab/redmine-apijs
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

if Rails::VERSION::MAJOR < 6 or ENV['redmine_apijs_gem']
  require 'redmine'
  require 'apijs_files'
  require 'apijs_attachment'
  require 'useragentparser'
end

if Redmine::VERSION::MAJOR >= 3
  if defined? Redmine.root
    ALL_FILES  = Redmine::Configuration['attachments_storage_path'] || File.join(Redmine.root, 'files')
    APIJS_ROOT = File.join(Redmine.root, 'tmp', 'apijs')
  else
    ALL_FILES  = Redmine::Configuration['attachments_storage_path'] || File.join(Rails.root, 'files')
    APIJS_ROOT = File.join(Rails.root, 'tmp', 'apijs')
  end
elsif ENV['RAILS_TMP']
  ALL_FILES  = Redmine::Configuration['attachments_storage_path'] || File.join(ENV['RAILS_VAR'], 'files')
  APIJS_ROOT = File.join(ENV['RAILS_TMP'], 'tmp', 'apijs')
elsif ENV['RAILS_CACHE']
  ALL_FILES  = Redmine::Configuration['attachments_storage_path'] || File.join(ENV['RAILS_VAR'], 'files')
  APIJS_ROOT = File.join(ENV['RAILS_CACHE'], 'tmp', 'apijs')
else
  ALL_FILES  = Redmine::Configuration['attachments_storage_path'] || File.join(Rails.root, 'files')
  APIJS_ROOT = File.join(Rails.root, 'tmp', 'apijs')
end

Redmine::Plugin.register :redmine_apijs do

  name 'Redmine Apijs plugin'
  author 'Fabrice Creuzot'
  description 'Integrate the apijs JavaScript library into Redmine. Provides a gallery for image and video attachments.'
  version '6.9.6'
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