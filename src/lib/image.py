#!/usr/bin/env python
# -*- coding: utf8 -*-
# Created J/26/12/2013
# Updated D/12/07/2020
#
# Copyright 2008-2020 | Fabrice Creuzot (luigifab) <code~luigifab~fr>
# https://www.luigifab.fr/openmage/apijs
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
from PIL import Image, ImageSequence

try:
	filein  = str(sys.argv[1])
	fileout = str(sys.argv[2])
	size    = (int(sys.argv[3]), int(sys.argv[4]))
	quality = int(sys.argv[5])
	fixed   = len(sys.argv) == 7 and sys.argv[6] == 'fixed'
except:
	print("Usage: image.py source destination width height [quality=0=auto] [fixed]")
	print("source: all supported format by python-pil (including animated gif/png/webp)")
	print("destination: jpg,png,gif,webp")
	exit(-1)

if not os.path.exists(os.path.dirname(fileout)):
	os.makedirs(os.path.dirname(fileout))

source = Image.open(filein)
if size[1] == 0 and size[0] == 0:
	size = (source.size[0], source.size[1])
elif size[1] == 0:
	size = (size[0], int(size[0] / (source.size[0] / source.size[1])))
elif size[0] == 0:
	size = (int(size[1] * (source.size[0] / source.size[1])), size[1])

# (Animated) PNG resizing (since PIL 7.1.0)
# based on https://stackoverflow.com/a/41827681/2980105
if source.format == 'PNG' and ".png" in fileout:

	frames = []
	try:
		while True:
			new_frame = Image.new('RGBA', source.size, (255,255,255,1))
			new_frame.paste(source, (0,0), source.convert('RGBA'))
			new_frame.thumbnail(size, Image.ANTIALIAS)

			if fixed:
				offset_x = int(max((size[0] - new_frame.size[0]) / 2, 0))
				offset_y = int(max((size[1] - new_frame.size[1]) / 2, 0))
				final_frame = Image.new('RGBA', size, (255,255,255,1))
				final_frame.paste(new_frame, (offset_x, offset_y))
				frames.append(final_frame)
			else:
				frames.append(new_frame)

			b = source.tell()
			source.seek(b + 1)
			if b == source.tell():
				break
	except EOFError:
		pass
# Animated GIF resizing
# based on https://stackoverflow.com/a/41827681/2980105
elif source.format == 'GIF' and source.is_animated and ".gif" in fileout:

	p = source.getpalette()
	frames = []
	try:
		while True:
			# If the GIF uses local colour tables, each frame will have its own palette.
			# If not, we need to apply the global palette to the new frame.
			if not source.getpalette():
				source.putpalette(p)

			new_frame = Image.new('RGBA', source.size, (255,255,255,1))
			new_frame.paste(source, (0,0), source.convert('RGBA'))
			new_frame.thumbnail(size, Image.ANTIALIAS)

			if fixed:
				offset_x = int(max((size[0] - new_frame.size[0]) / 2, 0))
				offset_y = int(max((size[1] - new_frame.size[1]) / 2, 0))
				final_frame = Image.new('RGBA', size, (255,255,255,1))
				final_frame.paste(new_frame, (offset_x, offset_y))
				frames.append(final_frame)
			else:
				frames.append(new_frame)

			b = source.tell()
			source.seek(b + 1)
			if b == source.tell():
				break
	except EOFError:
		pass
# Animated WEBP resizing (since PIL 5.0.0)
# based on https://stackoverflow.com/a/41827681/2980105
elif source.format == 'WEBP' and ".webp" in fileout:

	frames = []
	try:
		while True:
			new_frame = Image.new('RGBA', source.size, (255,255,255,1))
			new_frame.paste(source, (0,0), source.convert('RGBA'))
			new_frame.thumbnail(size, Image.ANTIALIAS)

			if fixed:
				offset_x = int(max((size[0] - new_frame.size[0]) / 2, 0))
				offset_y = int(max((size[1] - new_frame.size[1]) / 2, 0))
				final_frame = Image.new('RGBA', size, (255,255,255,1))
				final_frame.paste(new_frame, (offset_x, offset_y))
				frames.append(final_frame)
			else:
				frames.append(new_frame)

			b = source.tell()
			source.seek(b + 1)
			if b == source.tell():
				break
	except EOFError:
		pass
# Standard resizing
elif fixed:
	source.thumbnail(size, Image.ANTIALIAS)
	offset_x = int(max((size[0] - source.size[0]) / 2, 0))
	offset_y = int(max((size[1] - source.size[1]) / 2, 0))
	dest = Image.new('RGBA', size, (255,255,255,1))
	dest.paste(source, (offset_x, offset_y))
else:
	source.thumbnail(size, Image.ANTIALIAS)
	dest = Image.new('RGBA', (source.size[0], source.size[1]), (255,255,255,1))
	dest.paste(source)

# https://pillow.readthedocs.io/en/latest/handbook/image-file-formats.html
# source.info.get('loop')=None
if ".png" in fileout:
	# The image quality, on a scale from 0 (best-speed) to 9 (best-compression), the default is 6
	# but when optimize option is True compress_level has no effect
	try:
		if len(frames) == 1:
			frames[0].save(fileout, 'PNG', optimize=True, compress_level=9)
		else:
			frames[0].save(fileout, 'PNG', optimize=True, compress_level=9, save_all=True, append_images=frames[1:],
				loop=0, duration=source.info.get('duration'))
	except:
		dest.save(fileout, 'PNG', optimize=True, compress_level=9)
elif ".gif" in fileout:
	try:
		if len(frames) == 1:
			frames[0].save(fileout, 'GIF', optimize=True)
		else:
			frames[0].save(fileout, 'GIF', optimize=True, save_all=True, append_images=frames[1:],
				loop=0, duration=source.info.get('duration'), default_image=source.info.get('default_image'))
	except:
		dest.save(fileout, 'GIF', optimize=True)
elif ".webp" in fileout:
	# The image quality, on a scale from 0 (worst) to 100 (best), the default is 80 (lossy, 0 gives the smallest size and 100 the largest)
	# The method, on a scale from 0 (fast) to 6 (slower-better), the default is 0
	if quality < 1:
		quality = 80
	elif quality > 100:
		quality = 100
	try:
		if len(frames) == 1:
			frames[0].save(fileout, 'WEBP', method=5, quality=quality)
		else:
			frames[0].save(fileout, 'WEBP', method=5, quality=quality, save_all=True, append_images=frames[1:],
				loop=0, duration=source.info.get('duration'))
	except:
		dest.save(fileout, 'WEBP', method=5, quality=quality)
else:
	# The image quality, on a scale from 0 (worst) to 95 (best), the default is 75
	if quality < 1:
		quality = 75
	elif quality > 95:
		quality = 95
	dest.convert('RGB').save(fileout, 'JPEG', optimize=True, quality=quality)