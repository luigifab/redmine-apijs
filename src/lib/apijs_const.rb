# encoding: utf-8
# Created L/01/09/2014
# Updated J/30/04/2020
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

if Redmine::VERSION::MAJOR >= 3
	ALL_FILES  = Redmine::Configuration['attachments_storage_path'] || File.join(Redmine.root, 'files')
	APIJS_ROOT = File.join(Redmine.root, 'tmp', 'apijs')
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

# will be removed
root = (ENV['RAILS_TMP'].to_s.length > 0) ? (ENV['RAILS_TMP'].to_s + '/apijs') : nil
root = (!root && Rails.root.to_s.length > 0) ? (Rails.root.to_s + '/tmp/apijs') : root
root = (!root && RAILS_ROOT.to_s.length > 0) ? (RAILS_ROOT.to_s + '/tmp/apijs') : root
root = (!root) ? '/tmp/apijs' : root
APIJS_OLD_ROOT = root.to_s