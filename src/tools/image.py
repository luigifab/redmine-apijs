#!/usr/bin/env python
# -*- coding: utf8 -*-
#
# Created J/26/12/2013
# Updated V/31/10/2014
# Version 7
#
# Copyright 2008-2014 | Fabrice Creuzot (luigifab) <code~luigifab~info>
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

import os
import re
import sys
import Image

try:
	IN = str(sys.argv[1])
	OUT = str(sys.argv[2])
	SIZE = (int(sys.argv[3]), int(sys.argv[4]))
except:
	print "Usage: image.py sourceFileName destinationFileName thumbnailWidth thumbnailHeight"
	exit(-1)

# préparation
thumb = (SIZE[0] < 351) and True or False

video = re.compile('\.(ogv|webm|mp4|m4v)$')
video = video.search(IN) and True or False

png = re.compile('\.png$')
png = png.search(IN) and True or False

# vérification du dossier
if not os.path.exists(os.path.dirname(OUT)):
	os.makedirs(os.path.dirname(OUT))

# extraction de la miniature de la vidéo avec ffmpegthumbnailer
if (video):
	os.system('ffmpegthumbnailer -i ' + IN + ' -o ' + OUT + ' -q 10 -s 200')
	IN = OUT

# génération de la miniature et recentre l'image (demande explicite)
# génération de l'aperçu redimensionné si l'image dépasse SIZE[0] ou SIZE[1] (=> .thumbnail)
# à partir de l'image source (IN) vers l'image de destination (OUT) et à la taille demandée (SIZE)
sourceImg = Image.open(IN)

if ((thumb or (sourceImg.size[0] > SIZE[0]) or (sourceImg.size[1] > SIZE[1])) and not png):

	sourceImg.thumbnail(SIZE, Image.ANTIALIAS)

	if (thumb):
		offset_x = max((SIZE[0] - sourceImg.size[0]) / 2, 0)
		offset_y = max((SIZE[1] - sourceImg.size[1]) / 2, 0)
		finalImg = Image.new('RGBA', SIZE, (0,0,0,0))
		finalImg.paste(sourceImg, (offset_x, offset_y))
	else:
		finalImg = Image.new('RGBA', (sourceImg.size[0], sourceImg.size[1]), (0,0,0,0))
		finalImg.paste(sourceImg)

	if (video):
		playImg = Image.open(os.path.join(os.path.dirname(__file__).replace('tools', 'assets/images/humanity-player.png')))
		finalImg.paste(playImg, (0, 0), playImg)
else:
	finalImg = sourceImg

finalImg.save(OUT, 'JPEG')