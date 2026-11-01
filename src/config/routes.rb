# encoding: utf-8
# Created J/12/12/2013
# Updated D/01/11/2026
#
# Copyright 2008-2027 | Fabrice Creuzot (luigifab) <code~luigifab~fr>
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

if Redmine::VERSION::MAJOR >= 2
  RedmineApp::Application.routes.draw do

    match 'apijs/preview/:type/:id/:filename', to: 'apijs#preview',
      via: :get, type: /thumb|srcset|show/, id: /\d+/, filename: /.*/

    match 'apijs/download/:id/:filename', to: 'apijs#download',
      via: :get, id: /\d+/, filename: /.*/

    match 'apijs/edit/:type', to: 'apijs#edit',
      via: :post, type: /desc|name/

    match 'apijs/delete', to: 'apijs#delete',
      via: :post

    match 'apijs/clearcache', to: 'apijs#clearcache',
      via: :post
  end
else
  ActionController::Routing::Routes.draw do |map|

    map.connect 'apijs/preview/:type/:id/:filename',
      controller: 'apijs', action: 'preview',
      conditions: {method: :get}, type: /thumb|srcset|show/, id: /\d+/, filename: /.*/

    map.connect 'apijs/download/:id/:filename',
      controller: 'apijs', action: 'download',
      conditions: {method: :get}, id: /\d+/, filename: /.*/

    map.connect 'apijs/edit/:type',
      controller: 'apijs', action: 'edit',
      conditions: {method: :post}, type: /desc|name/

    map.connect 'apijs/delete',
      controller: 'apijs', action: 'delete',
      conditions: {method: :post}

    map.connect 'apijs/clearcache',
      controller: 'apijs', action: 'clearcache',
      conditions: {method: :post}
  end
end