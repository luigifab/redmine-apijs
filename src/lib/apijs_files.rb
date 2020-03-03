# encoding: utf-8
# Created L/21/05/2012
# Updated V/03/01/2020
#
# Copyright 2008-2020 | Fabrice Creuzot (luigifab) <code~luigifab~fr>
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

class ApijsFiles < Redmine::Hook::ViewListener

  def view_layouts_base_html_head(context = { })
    rtl = l(:direction) == 'rtl'
    if Setting.plugin_redmine_apijs['enabled'] == '1'
      #stylesheet_link_tag(langrtl && rtl ? 'apijs-screen-rtl.min.css' : 'apijs-screen.min.css', :plugin => 'redmine_apijs', :media => 'screen') +
      stylesheet_link_tag('apijs-screen.min.css', :plugin => 'redmine_apijs', :media => 'screen') +
        stylesheet_link_tag(rtl ? 'apijs-redmine-rtl.min.css' : 'apijs-redmine.min.css', :plugin => 'redmine_apijs', :media => 'screen') +
        stylesheet_link_tag('apijs-print.min.css', :plugin => 'redmine_apijs', :media => 'print') +
        javascript_include_tag('apijs.min.js', :plugin => 'redmine_apijs') +
        javascript_include_tag('apijs-redmine.min.js', :plugin => 'redmine_apijs')
    else
      stylesheet_link_tag(rtl ? 'apijs-redmine-rtl.min.css' : 'apijs-redmine.min.css', :plugin => 'redmine_apijs', :media => 'screen')
    end
  end

  def view_layouts_base_body_top(context = { })
    if Setting.plugin_redmine_apijs['browser'] == '1'
      controller = context[:controller]
      Thread.current[:request] = controller.request
      controller.render partial: 'browser'
    end
  end
end