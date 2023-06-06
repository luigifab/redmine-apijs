#!/usr/bin/python3
# -*- coding: utf8 -*-
# Created J/26/12/2013
# Updated M/23/05/2023
#
# Copyright 2008-2023 | Fabrice Creuzot (luigifab) <code~luigifab~fr>
# Copyright 2020-2023 | Fabrice Creuzot <fabrice~cellublue~com>
# https://github.com/luigifab/redmine-apijs https://github.com/luigifab/openmage-apijs
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

import os, sys

try:
	filein  = str(sys.argv[1])
	fileout = str(sys.argv[2])
	size    = (int(sys.argv[3]), int(sys.argv[4]))
	quality = int(sys.argv[5]) if len(sys.argv) >= 6 else 0
	fixed   = len(sys.argv) >= 7 and sys.argv[6] == 'fixed'
except:
	print("Usage: image.py source_file destination_file width_px height_px [quality=0:auto..100 or 0:auto..9 for png] [fixed]")
	print("source: all supported format by python-pil (including animated gif/png/webp),")
	print("     or all supported format by ffmpegthumbnailer,")
	print("     or svg")
	print("destination: jpg,gif,png,webp or svg")
	exit(-1)

# https://stackoverflow.com/a/273227/2980105
if not os.path.exists(os.path.dirname(fileout)):
	os.makedirs(os.path.dirname(fileout), exist_ok=True)

same    = filein == fileout
fileout = fileout + '.save'
if os.path.isfile(fileout):
	exit(0)
os.close(os.open(fileout, os.O_CREAT))


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

	# https://pillow.readthedocs.io/en/latest/releasenotes/9.1.0.html
	# https://pillow.readthedocs.io/en/latest/releasenotes/7.0.0.html?highlight=thumbnail (reducing_gap)
	# https://pillow.readthedocs.io/en/latest/reference/Image.html#PIL.Image.Image.thumbnail
	# https://pillow.readthedocs.io/en/latest/handbook/concepts.html#filters-comparison-table
	# https://pillow.readthedocs.io/en/latest/reference/Image.html#PIL.Image.Image.paste
	if hasattr(Image, '__version__') and versionTuple(Image.__version__) >= (9,1,0):
		source.thumbnail(size, Image.Resampling.LANCZOS, 4)
	elif hasattr(Image, '__version__') and versionTuple(Image.__version__) >= (7,0,0):
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

def videoToImage(filein, fileout, size):

	os.system('ffmpegthumbnailer -i ' + filein + ' -o ' + fileout + ' -q 10 -s ' + str(size[0]))
	if os.path.isfile(fileout) and os.path.getsize(fileout) > 0:
		img = Image.open(fileout)
	else:
		img = Image.new('RGBA', size, (0,0,0,0))

	return img

def hasTransparency(img):

	# https://stackoverflow.com/a/58567453/2980105
	if img.mode == 'P':
		transparent = img.info.get('transparency', -1)
		for _, index in img.getcolors():
			if index == transparent:
				return True
	elif img.mode == 'RGBA':
		extrema = img.getextrema()
		if extrema[3][0] < 255:
			return True

	return False


# Animated resizing
# https://stackoverflow.com/a/41827681/2980105
def resizeAnimatedGif(source, size, fixed):

	# Animated GIF resizing
	# https://pillow.readthedocs.io/en/latest/handbook/image-file-formats.html#gif
	colors = source.getpalette()
	dest = []

	try:
		while True:
			# If the GIF uses local colour tables, each frame will have its own palette.
			# If not, we need to apply the global palette to the new frame.
			# Ignore ValueError (illegal image mode)
			try:
				if not source.getpalette():
					source.putpalette(colors)
			except ValueError:
				pass

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
			dest[0].save(fileout, 'PNG', optimize=True, compress_level=quality)
		else:
			dest[0].save(fileout, 'PNG', optimize=True, compress_level=quality, save_all=True, append_images=dest[1:],
				loop=0, duration=source.info.get('duration'))
	except:
		dest.save(fileout, 'PNG', optimize=True, compress_level=quality)

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

	# https://github.com/wanadev/pyguetzli
	# warning: extremely slow performance (https://github.com/google/guetzli/issues/50)
	#try:
	#	import pyguetzli
	#	filefinal = pyguetzli.process_pil_image(dest.convert('RGB'), quality)
	#	output = open(fileout, "wb")
	#	output.write(filefinal)
	#except ImportError:
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

	if ".ogv" in filein or ".webm" in filein or ".mp4" in filein:
		# from video
		source = videoToImage(filein, fileout, size)
		imgext = 'VIDEO'
	else:
		# from image
		source = Image.open(filein)
		imgext = source.format
		size   = calcSize(source, size)

	# filein = fileout = /tmp/phpA5kbkc  when replace tmp image with re-sampled copy to exclude images with malicious data
	if   imgext == 'GIF'  and (same or ".gif"  in fileout):
		dest = resizeAnimatedGif(source, size, fixed)
		saveGif(dest, fileout, quality)
	elif imgext == 'GIF'  and (same or ".webp" in fileout):
		dest = resizeAnimatedGif(source, size, fixed)
		saveWebp(dest, fileout, quality)
	elif imgext == 'PNG'  and (same or ".png"  in fileout):
		dest = resizeAnimatedPng(source, size, fixed)
		savePng(dest, fileout, quality)
	elif imgext == 'PNG'  and (same or ".webp" in fileout):
		dest = resizeAnimatedPng(source, size, fixed)
		saveWebp(dest, fileout, quality)
	elif imgext == 'WEBP' and (same or ".webp" in fileout):
		dest = resizeAnimatedWebp(source, size, fixed)
		saveWebp(dest, fileout, quality)
	else:
		if imgext == 'VIDEO':
			# from video
			offset_x = max(int((size[0] - source.size[0]) / 2), 0)
			offset_y = max(int((size[1] - source.size[1]) / 2), 0)
			# Color detection
			# white background black player OR black background white player
			pixels = source.getcolors(size[0] * size[1])
			pixels = sorted(pixels, key=lambda t: t[0])
			if (pixels[-1][1] > (127,127,127)):
				dest = Image.new('RGBA', size, (255,255,255,0))
				dest.paste(source, (offset_x, offset_y))
				# https://stackoverflow.com/a/59082116 (replace only last lib)
				# /var/lib/gems/xyz/gems/redmine_apijs-xyz/lib » /var/lib/gems/xyz/gems/redmine_apijs-xyz/assets/images/...
				path = os.path.dirname(__file__)
				path = ('/assets/images/apijs/player-black-' + str(size[0]) + '.png').join(path.rsplit('/lib', 1))
				play = Image.open(path)
				dest.paste(play, (0, 0), play)
			else:
				dest = Image.new('RGBA', size, (0,0,0,0))
				dest.paste(source, (offset_x, offset_y))
				# https://stackoverflow.com/a/59082116 (replace only last lib)
				# /var/lib/gems/xyz/gems/redmine_apijs-xyz/lib » /var/lib/gems/xyz/gems/redmine_apijs-xyz/assets/images/...
				path = os.path.dirname(__file__)
				path = ('/assets/images/apijs/player-white-' + str(size[0]) + '.png').join(path.rsplit('/lib', 1))
				play = Image.open(path)
				dest.paste(play, (0, 0), play)
		else:
			# from image
			# Auto rotate image
			# https://github.com/python-pillow/Pillow/commit/1ba774ae7faf93355b85c7b005fbaf0b0e66d426
			if hasattr(Image, '__version__') and versionTuple(Image.__version__) >= (6,0,0) and source.getexif().get(0x0112):
				from PIL import ImageOps
				source = ImageOps.exif_transpose(source)
			# create thumbnail
			dest = createThumb(source, size, fixed, True)

		if hasTransparency(source) is False:
			dest = dest.convert('RGB')

		if ".gif"    in fileout or (same and imgext == 'GIF'):
			saveGif(dest, fileout, quality)
		elif ".png"  in fileout or (same and imgext == 'PNG'):
			savePng(dest, fileout, quality)
		elif ".webp" in fileout or (same and imgext == 'WEBP'):
			saveWebp(dest, fileout, quality)
		else:
			saveJpg(dest, fileout, quality)

if os.path.isfile(fileout):
	os.rename(fileout, fileout.replace('.save', ''))

exit(0)