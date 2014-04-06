#!/usr/bin/env python
# -*- coding: utf8 -*-
#
# Created J/26/12/2013
# Updated V/28/02/2014
# Version 4
#
# Copyright 2013-2014 | Fabrice Creuzot (luigifab) <code~luigifab~info>
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
import sys
import Image

# récupération des paramètres
try:
	IN = str(sys.argv[1])
	OUT = str(sys.argv[2])
	SIZE = (int(sys.argv[3]), int(sys.argv[4]))
	VIDEO = (len(sys.argv) == 6) and True or False
except:
	print "Usage: image.py sourceFileName destinationFileName thumbnailWidth thumbnailHeight [video]"
	print "use 'video' if the sourceFileName is a video"
	exit(-1)

# vérification du répertoire
if not os.path.exists(os.path.dirname(OUT)):
	os.makedirs(os.path.dirname(OUT))

# extraction de la miniature de la vidéo avec ffmpegthumbnailer
if (VIDEO):
	os.system('ffmpegthumbnailer -i ' + IN + ' -o ' + OUT + ' -q 10 -s 200')
	IN = OUT

# génération de la miniature si la largeur demandée est inférieur à 500 px
# génération de l'aperçu ou de la miniature si l'image fait plus de 850 Ko ou si elle dépasse SIZE[0] ou SIZE[1]
# à partir de l'image source (IN) vers l'image de destination (OUT) et à la taille demandée (SIZE)
sourceImg = Image.open(IN)

if (SIZE[0] < 500) or (os.path.getsize(IN) > 850 * 1024) or (sourceImg.size[0] > SIZE[0]) or (sourceImg.size[1] > SIZE[1]):
	sourceImg.thumbnail(SIZE, Image.ANTIALIAS)

	offset_x = max((SIZE[0] - sourceImg.size[0]) / 2, 0)
	offset_y = max((SIZE[1] - sourceImg.size[1]) / 2, 0)
	offset_tuple = (offset_x, offset_y)

	finalImg = Image.new('RGBA', SIZE, (0,0,0,0))
	finalImg.paste(sourceImg, offset_tuple)

	if (VIDEO):
		playImg = Image.open(os.path.join(os.path.dirname(__file__).replace('tools', 'assets/images/humanity-player.png')))
		finalImg.paste(playImg, (0, 0), playImg)

	finalImg.save(OUT, 'JPEG')
else:
	sourceImg.save(OUT, 'JPEG')