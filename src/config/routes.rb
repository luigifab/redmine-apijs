# encoding: utf-8
# Created J/12/12/2013
# Updated S/16/01/2021
#
# Copyright 2008-2023 | Fabrice Creuzot (luigifab) <code~luigifab~fr>
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

    match 'apijs/thumb/:id/:filename', to: 'apijs#thumb',
      id: /\d+/, filename: /.*/, via: :get

    match 'apijs/srcset/:id/:filename', to: 'apijs#srcset',
      id: /\d+/, filename: /.*/, via: :get

    match 'apijs/show/:id/:filename', to: 'apijs#show',
      id: /\d+/, filename: /.*/, via: :get

    match 'apijs/download/:id/:filename', to: 'apijs#download',
      id: /\d+/, filename: /.*/, via: :get

    match 'apijs/download/:inline/:id/:filename', to: 'apijs#download',
      inline: 'inline', id: /\d+/, filename: /.*/, via: :get

    match 'attachments/download/:id', to: 'apijs#download',
      id: /\d+/, via: :get

    match 'apijs/editdesc', to: 'apijs#editdesc',
      via: :post

    match 'apijs/editname', to: 'apijs#editname',
      via: :post

    match 'apijs/delete', to: 'apijs#delete',
      via: :post

    match 'apijs/clearcache', to: 'apijs#clearcache',
      via: :get
  end
else
  ActionController::Routing::Routes.draw do |map|

    map.connect 'apijs/thumb/:id/:filename',
      controller: 'apijs', action: 'thumb',
      id: /\d+/, filename: /.*/,
      conditions: {method: :get}

    map.connect 'apijs/srcset/:id/:filename',
      controller: 'apijs', action: 'srcset',
      id: /\d+/, filename: /.*/,
      conditions: {method: :get}

    map.connect 'apijs/show/:id/:filename',
      controller: 'apijs', action: 'show',
      id: /\d+/, filename: /.*/,
      conditions: {method: :get}

    map.connect 'apijs/download/:id/:filename',
      controller: 'apijs', action: 'download',
      id: /\d+/, filename: /.*/,
      conditions: {method: :get}

    map.connect 'apijs/download/:inline/:id/:filename',
      controller: 'apijs', action: 'download',
      inline: 'inline', id: /\d+/, filename: /.*/,
      conditions: {method: :get}

    map.connect 'attachments/download/:id',
      controller: 'apijs', action: 'download',
      id: /\d+/,
      conditions: {method: :get}

    map.connect 'apijs/editdesc',
      controller: 'apijs', action: 'editdesc',
      conditions: {method: :post}

    map.connect 'apijs/editname',
      controller: 'apijs', action: 'editname',
      conditions: {method: :post}

    map.connect 'apijs/delete',
      controller: 'apijs', action: 'delete',
      conditions: {method: :post}

    map.connect 'apijs/clearcache',
      controller: 'apijs', action: 'clearcache',
      conditions: {method: :get}
  end
end