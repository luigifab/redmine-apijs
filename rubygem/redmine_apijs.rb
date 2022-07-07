# encoding: utf-8
# Created L/13/07/2020
# Updated M/05/07/2022
#
# Copyright 2008-2022 | Fabrice Creuzot (luigifab) <code~luigifab~fr>
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

      # for Redmine 5.0+ with Rails 6.0+
      ENV['redmine_apijs_gem'] = 'yes'

      # Gemify redmine plugin (based on https://github.com/koppen/redmine_github_hook/commit/a82bcccfd0731503509771d3f715d8fb1e6f1bfe)
      # it works out of box with Redmine 3.0 - 4.0, for Redmine 4.1+ see https://www.redmine.org/issues/31110
      # run the classic redmine plugin initializer after rails boot
      require File.expand_path('../../init', __FILE__)
      ::ActionController::Base.prepend_view_path(File.expand_path('../../app/views/', __FILE__))

      # and copy plugin assets
      unless ::Redmine::Configuration['mirror_plugins_assets_on_startup'] == false
        if Redmine::VERSION::MAJOR >= 5
          # https://github.com/redmine/redmine/blob/9aa34eb651e2941aeae69cc3acf6e1c1b909729e/lib/redmine/plugin_loader.rb#L41
          # Update the name of the plugin directory
          module ::Redmine
            class PluginPath
              def update_dir(dir)
                @dir = dir
              end
            end
          end
          # go
          obj = Redmine::PluginPath.new(File.expand_path('../../', __FILE__))
          obj.update_dir('redmine_apijs')
          obj.mirror_assets
        else
          # https://github.com/redmine/redmine/blob/94f3510036690d049ac7425d19fa7c055044ae57/lib/redmine/plugin.rb#L207
          # Returns the absolute path to the plugin assets directory
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
          # go
          Redmine::Plugin.mirror_assets('redmine_apijs')
        end
      end
    end
  end
end