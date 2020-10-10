#!/usr/bin/env python
# -*- coding: utf8 -*-
# Created J/26/12/2013
# Updated D/27/09/2020
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
	size    = (int(sys.argv[3]), int(sys.argv[4]))
	quality = int(sys.argv[5])
except:
	print("Usage: video.py source destination width height [quality=0=auto]")
	print("source: ogv,webm,mp4")
	print("destination: jpg")
	exit(-1)

if not os.path.exists(os.path.dirname(fileout)):
	os.makedirs(os.path.dirname(fileout))

os.system('ffmpegthumbnailer -i ' + filein + ' -o ' + fileout + ' -q 10 -s ' + str(size[0]))
if os.path.isfile(fileout):
	filein = fileout
	source = Image.open(filein)
else:
	source = Image.new('RGBA', size, (0,0,0,0))

# Standard resizing
source.thumbnail(size, Image.ANTIALIAS)
offset_x = int(max((size[0] - source.size[0]) / 2, 0))
offset_y = int(max((size[1] - source.size[1]) / 2, 0))

# Color detection
pixels = source.getcolors(size[0] * size[1])
pixels = sorted(pixels, key=lambda t: t[0])
if (pixels[-1][1] > (127,127,127)): # white background, black player
	dest = Image.new('RGBA', size, (255,255,255,0))
	dest.paste(source, (offset_x, offset_y))
	# https://stackoverflow.com/a/59082116 (replace only last lib)
	# /var/lib/gems/xyz/gems/redmine_apijs-xyz/lib devient /var/lib/gems/xyz/gems/redmine_apijs-xyz/assets/images/...
	path = os.path.dirname(__file__)
	path = ('/assets/images/apijs/player-black-' + str(size[0]) + '.png').join(path.rsplit('/lib', 1))
	play = Image.open(path)
	dest.paste(play, (0, 0), play)
else:
	dest = Image.new('RGBA', size, (0,0,0,0))
	dest.paste(source, (offset_x, offset_y))
	# https://stackoverflow.com/a/59082116 (replace only last lib)
	# /var/lib/gems/xyz/gems/redmine_apijs-xyz/lib devient /var/lib/gems/xyz/gems/redmine_apijs-xyz/assets/images/...
	path = os.path.dirname(__file__)
	path = ('/assets/images/apijs/player-white-' + str(size[0]) + '.png').join(path.rsplit('/lib', 1))
	play = Image.open(path)
	dest.paste(play, (0, 0), play)

# https://pillow.readthedocs.io/en/latest/handbook/image-file-formats.html
# The image quality, on a scale from 0 (worst) to 95 (best), the default is 75
if quality < 1:
	quality = 75
elif quality > 95:
	quality = 95
dest.convert('RGB').save(fileout, 'JPEG', optimize=True, quality=quality)