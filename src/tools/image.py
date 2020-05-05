#!/usr/bin/env python
# -*- coding: utf8 -*-
# Created J/26/12/2013
# Updated D/03/05/2020
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

import os
import re
import sys
from PIL import Image

try:
	filein  = str(sys.argv[1])
	fileout = str(sys.argv[2])
	sizes   = (int(sys.argv[3]), int(sys.argv[4]))
except:
	print("Usage: image.py source destination width height")
	print("source: jpg,jpeg,png ogv,webm,mp4,m4v pdf,psd,eps,tif,tiff")
	print("destination: jpg,png")
	exit(-1)

video = re.compile('\.(ogv|webm|mp4|m4v)$')
video = video.search(filein) and True or False
pdf   = re.compile('\.pdf$')
pdf   = pdf.search(filein) and True or False
thumb = (sizes[0] < 351) and True or False

if not os.path.exists(os.path.dirname(fileout)):
	os.makedirs(os.path.dirname(fileout))

if (video):
	os.system('ffmpegthumbnailer -i ' + filein + ' -o ' + fileout + ' -q 10 -s 200')
	filein = fileout
elif (pdf):
	os.system('gs -dSAFER -dBATCH -sDEVICE=jpeg -dTextAlphaBits=4 -dGraphicsAlphaBits=4 -dFirstPage=1 -dLastPage=1 -dNOPAUSE -dBATCH -r300 -sOutputFile=' + fileout + ' ' + filein)
	filein = fileout

source = Image.open(filein)
if (thumb or (source.size[0] > sizes[0]) or (source.size[1] > sizes[1])):

	source.thumbnail(sizes, Image.ANTIALIAS)

	if (thumb):
		offset_x = int(max((sizes[0] - source.size[0]) / 2, 0))
		offset_y = int(max((sizes[1] - source.size[1]) / 2, 0))
		dest = Image.new('RGBA', sizes, (0,0,0,0))
		dest.paste(source, (offset_x, offset_y))
	else:
		dest = Image.new('RGBA', (source.size[0], source.size[1]), (0,0,0,0))
		dest.paste(source)

	if (video):
		play = Image.open(os.path.join(os.path.dirname(__file__).replace('tools', 'assets/images/apijs/player.png')))
		dest.paste(play, (0, 0), play)
else:
	dest = source

if ".png" in fileout:
	dest.convert('RGB').save(fileout, 'PNG')
else:
	dest.convert('RGB').save(fileout, 'JPEG')