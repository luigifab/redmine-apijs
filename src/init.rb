# encoding: utf-8
#
# Created L/21/05/2012
# Updated V/10/01/2014
# Version 13
#
# Copyright 2012-2014 | Fabrice Creuzot (luigifab) <code~luigifab~info>
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
require 'files_hook'
require 'attachment_patch'

Redmine::Plugin.register :redmine_apijs do
  name 'Redmine Apijs plugin'
  author 'Fabrice Creuzot'
  description 'Integrate the apijs javascript library into Redmine.'
  version '5.0.0'
  url 'https://redmine.luigifab.info/projects/redmine/wiki/apijs'
  author_url 'http://www.luigifab.info/'

  settings :partial => 'settings/apijs'
  permission :edit_attachments, { :apijs => :edit }, { :require => :loggedin }
  permission :delete_attachments, { :apijs => :delete }, { :require => :loggedin, :require => :member }
end