#!/usr/bin/python3
# -*- coding: utf8 -*-
# Created J/26/12/2013
# Updated M/11/05/2021
#
# Copyright 2008-2022 | Fabrice Creuzot (luigifab) <code~luigifab~fr>
# Copyright 2020-2022 | Fabrice Creuzot <fabrice~cellublue~com>
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
import sys

try:
	filein  = str(sys.argv[1])
	fileout = str(sys.argv[2])
	size    = (int(sys.argv[3]), int(sys.argv[4]))
	quality = int(sys.argv[5])
	fixed   = len(sys.argv) == 7 and sys.argv[6] == 'fixed'
except:
	print("Usage: image.py source destination width height [quality=0=auto] [fixed]")
	print("source: all supported format by python-pil (including animated gif/png/webp) or svg")
	print("destination: jpg,png,gif,webp or svg")
	exit(-1)

if not os.path.exists(os.path.dirname(fileout)):
	os.makedirs(os.path.dirname(fileout))

fileout = fileout + '.save'


# tools
def versionTuple(v):
	return tuple(map(int, (v.split('.'))))

def calcSize(source, size):

	if size[1] == 0 and size[0] == 0:
		return source.size
	if size[1] == 0:
		return (size[0], int(size[0] / (source.size[0] / source.size[1])))
	if size[0] == 0:
		return (int(size[1] * (source.size[0] / source.size[1])), size[1])

	return size

def createThumb(source, size, fixed, new=False):

	# https://pillow.readthedocs.io/en/latest/reference/Image.html#PIL.Image.Image.thumbnail
	# https://pillow.readthedocs.io/en/latest/handbook/concepts.html#filters-comparison-table
	# https://pillow.readthedocs.io/en/latest/reference/Image.html#PIL.Image.Image.paste
	if hasattr(Image, '__version__') and versionTuple(Image.__version__) > (7,0,0):
		source.thumbnail(size, Image.LANCZOS, 4)
	else:
		source.thumbnail(size, Image.ANTIALIAS)

	if fixed:
		offset_x = max(int((size[0] - source.size[0]) / 2), 0)
		offset_y = max(int((size[1] - source.size[1]) / 2), 0)
		dest = Image.new('RGBA', size, (255,255,255,1))
		dest.paste(source, (offset_x, offset_y))
	elif new:
		if (source.size < size):
			dest = Image.new('RGBA', source.size, (255,255,255,1))
			dest.paste(source)
		else:
			dest = Image.new('RGBA', size, (255,255,255,1))
			dest.paste(source)
	else:
		dest = source

	return dest


# Animated resizing
# based on https://stackoverflow.com/a/41827681/2980105
def resizeAnimatedGif(source, size, fixed):

	# Animated GIF resizing
	# https://pillow.readthedocs.io/en/latest/handbook/image-file-formats.html#gif
	colors = source.getpalette()
	dest = []

	try:
		while True:
			# If the GIF uses local colour tables, each frame will have its own palette.
			# If not, we need to apply the global palette to the new frame.
			if not source.getpalette():
				source.putpalette(colors)

			frame = Image.new('RGBA', source.size, (255,255,255,1))
			frame.paste(source, (0,0), source.convert('RGBA'))
			dest.append(createThumb(frame, size, fixed))

			idx = source.tell()
			source.seek(idx + 1)
			if idx == source.tell():
				break
	except EOFError:
		pass

	return dest

def resizeAnimatedPng(source, size, fixed):

	# Animated PNG resizing (since PIL 7.1.0)
	# https://pillow.readthedocs.io/en/latest/handbook/image-file-formats.html#apng-sequences
	dest = []

	try:
		while True:
			frame = Image.new('RGBA', source.size, (255,255,255,1))
			frame.paste(source, (0,0), source.convert('RGBA'))
			dest.append(createThumb(frame, size, fixed))

			idx = source.tell()
			source.seek(idx + 1)
			if idx == source.tell():
				break
	except EOFError:
		pass

	return dest

def resizeAnimatedWebp(source, size, fixed):

	# Animated WEBP resizing (since PIL 5.0.0)
	# https://pillow.readthedocs.io/en/latest/handbook/image-file-formats.html#webp
	dest = []

	try:
		while True:
			frame = Image.new('RGBA', source.size, (255,255,255,1))
			frame.paste(source, (0,0), source.convert('RGBA'))
			dest.append(createThumb(frame, size, fixed))

			idx = source.tell()
			source.seek(idx + 1)
			if idx == source.tell():
				break
	except EOFError:
		pass

	return dest


# File saving
# https://pillow.readthedocs.io/en/latest/handbook/image-file-formats.html
# todo: source.info.get('loop')=None
def saveGif(dest, fileout, quality):

	try:
		if len(dest) == 1:
			dest[0].save(fileout, 'GIF', optimize=True)
		else:
			dest[0].save(fileout, 'GIF', optimize=True, save_all=True, append_images=dest[1:],
				loop=0, duration=source.info.get('duration'), default_image=source.info.get('default_image'))
	except:
		dest.save(fileout, 'GIF', optimize=True)

def savePng(dest, fileout, quality):

	# The image quality, on a scale from 0 (best-speed) to 9 (best-compression), the default is 6
	# but when optimize option is True compress_level has no effect
	if quality < 1:
		quality = 6
	elif quality > 9:
		quality = 9

	try:
		if len(dest) == 1:
			dest[0].save(fileout, 'PNG', optimize=True, compress_level=9)
		else:
			dest[0].save(fileout, 'PNG', optimize=True, compress_level=9, save_all=True, append_images=dest[1:],
				loop=0, duration=source.info.get('duration'))
	except:
		dest.save(fileout, 'PNG', optimize=True, compress_level=9)

def saveWebp(dest, fileout, quality):

	# The image quality, on a scale from 0 (worst) to 100 (best), the default is 80 (lossy, 0 gives the smallest size and 100 the largest)
	# The method, on a scale from 0 (fast) to 6 (slower-better), the default is 0
	if quality < 1:
		quality = 80
	elif quality > 100:
		quality = 100

	try:
		if len(dest) == 1:
			dest[0].save(fileout, 'WEBP', method=5, quality=quality)
		else:
			dest[0].save(fileout, 'WEBP', method=5, quality=quality, save_all=True, append_images=dest[1:],
				loop=0, duration=source.info.get('duration'))
	except:
		dest.save(fileout, 'WEBP', method=5, quality=quality)

def saveJpg(dest, fileout, quality):

	# The image quality, on a scale from 0 (worst) to 95 (best), the default is 75
	if quality < 1:
		quality = 75
	elif quality > 95:
		quality = 95

	dest.convert('RGB').save(fileout, 'JPEG', optimize=True, subsampling=0, quality=quality)


# python-scour
if ".svg" in fileout:
	from scour.scour import sanitizeOptions, start
	options = sanitizeOptions()
	options.strip_xml_prolog = True # --strip-xml-prolog
	options.remove_metadata = True  # --remove-metadata
	options.strip_comments = True   # --enable-comment-stripping
	options.strip_ids = True        # --enable-id-stripping
	options.indent_type = None      # --indent=none
	start(options, open(filein, 'rb'), open(fileout, 'wb'))
# python-pil
else:
	from PIL import Image, ImageSequence
	source = Image.open(filein)
	size   = calcSize(source, size)

	if   source.format == 'GIF'  and ".gif"  in fileout:
		dest = resizeAnimatedGif(source, size, fixed)
		saveGif(dest, fileout, quality)
	elif source.format == 'PNG'  and ".png"  in fileout:
		dest = resizeAnimatedPng(source, size, fixed)
		savePng(dest, fileout, quality)
	elif source.format == 'WEBP' and ".webp" in fileout:
		dest = resizeAnimatedWeb(source, size, fixed)
		saveWebp(dest, fileout, quality)
	else:
		dest = createThumb(source, size, fixed, True)
		saveJpg(dest, fileout, quality)

if os.path.isfile(fileout):
	os.rename(fileout, fileout.replace('.save', ''))

exit(0)