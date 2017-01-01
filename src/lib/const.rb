# encoding: utf-8
# Created L/01/09/2014
# Updated M/08/11/2016
#
# Copyright 2008-2017 | Fabrice Creuzot (luigifab) <code~luigifab~info>
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

root = (ENV['RAILS_TMP'].to_s.length > 0) ? (ENV['RAILS_TMP'].to_s + '/apijs') : nil   # /var/cache/redmine/default/apijs/
root = (!root && Rails.root.to_s.length > 0) ? (Rails.root.to_s + '/tmp/apijs') : root # /home/user/redmine-2.5.1/tmp/apijs/
root = (!root && RAILS_ROOT.to_s.length > 0) ? (RAILS_ROOT.to_s + '/tmp/apijs') : root # /home/user/redmine-2.5.1/tmp/apijs/
root = (!root) ? '/tmp/apijs' : root                                                   # /tmp/apijs/
APIJS_ROOT = root.to_s