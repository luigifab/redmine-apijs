# encoding: utf-8
# Created L/21/05/2012
# Updated M/28/02/2017
#
# Copyright 2008-2018 | Fabrice Creuzot (luigifab) <code~luigifab~info>
# https://www.luigifab.info/redmine/apijs
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

class FilesHook < Redmine::Hook::ViewListener
  def view_layouts_base_html_head(context = { })
    if Setting.plugin_redmine_apijs['enabled'] == '1'
      stylesheet_link_tag('apijs-screen.min.css', 'apijs-redmine.min.css', :plugin => 'redmine_apijs', :media => 'screen') +
        stylesheet_link_tag('apijs-print.min.css', :plugin => 'redmine_apijs', :media => 'print') +
        javascript_include_tag('apijs.min.js', :plugin => 'redmine_apijs') +
        javascript_include_tag('apijs-album.min.js', :plugin => 'redmine_apijs')
    else
      stylesheet_link_tag('apijs-redmine.min.css', :plugin => 'redmine_apijs', :media => 'screen')
    end
  end
end