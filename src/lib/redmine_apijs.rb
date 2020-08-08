# encoding: utf-8
# Created L/13/07/2020
# Updated L/13/07/2020
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

require 'rails/engine'

module RedmineApijs

  # Gemify redmine plugin (https://github.com/koppen/redmine_github_hook/commit/a82bcccfd0731503509771d3f715d8fb1e6f1bfe)
  # Run the classic redmine plugin initializer after rails boot
  class Plugin < ::Rails::Engine
    config.after_initialize do
      require File.expand_path('../../init', __FILE__)
      ::ActionController::Base.prepend_view_path(File.expand_path('../../app/views/', __FILE__))
    end
  end
end