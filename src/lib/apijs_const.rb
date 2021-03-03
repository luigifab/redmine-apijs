# encoding: utf-8
# Created L/01/09/2014
# Updated J/23/07/2020
#
# Copyright 2008-2021 | Fabrice Creuzot (luigifab) <code~luigifab~fr>
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