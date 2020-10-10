# encoding: utf-8
# Created L/13/07/2020
# Updated D/27/08/2020
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

  class Plugin < ::Rails::Engine
    config.after_initialize do

      # Gemify redmine plugin (https://github.com/koppen/redmine_github_hook/commit/a82bcccfd0731503509771d3f715d8fb1e6f1bfe)
      # run the classic redmine plugin initializer after rails boot
      require File.expand_path('../../init', __FILE__)
      ::ActionController::Base.prepend_view_path(File.expand_path('../../app/views/', __FILE__))

      # and copy plugin assets
      unless ::Redmine::Configuration['mirror_plugins_assets_on_startup'] == false
        module ::Redmine
          class Plugin
            def assets_directory
              if directory =~ /redmine_apijs/
                File.join(File.expand_path('../../', __FILE__), 'assets')
              else
                File.join(directory, 'assets')
              end
            end
          end
        end
        Redmine::Plugin.mirror_assets('redmine_apijs')
      end

    end
  end
end