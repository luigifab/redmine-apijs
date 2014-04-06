<?php
/**
 * Created J/26/12/2013
 * Updated J/26/12/2013
 * Version 1
 *
 * Copyright 2013-2014 | Fabrice Creuzot (luigifab) <code~luigifab~info>
 * https://redmine.luigifab.info/projects/redmine/wiki/apijs
 *
 * This program is free software, you can redistribute it or modify
 * it under the terms of the GNU General Public License (GPL) as published
 * by the free software foundation, either version 2 of the license, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but without any warranty, without even the implied warranty of
 * merchantability or fitness for a particular purpose. See the
 * GNU General Public License (GPL) for more details.
 */

error_reporting(E_ALL);
date_default_timezone_set('UTC');
ini_set('max_execution_time', 1000);
ini_set('display_errors', 1);

header('Content-Type: text/plain');

$db = mysqli_connect('SERVER', 'USER', 'PASSWORD', 'DATABASE');
$dir = 'THE_REDMINE_FILES_DIRECTORY';

if ($handle = opendir($dir)) {

	while (($file = readdir($handle)) !== false) {

		if (($file !== '.') && ($file !== '..')) {

			$date = null;
			exec('exiftool -FastScan -IgnoreMinorErrors -DateTimeOriginal '.$dir.$file.' | cut -c35-', $date);

			if (isset($date[0])) {

				//exec('exiftool -xmp:creator="FirstName LastName <email@you.me>" -xmp:description="https://redmine.luigifab.info/projects/example/wiki" -xmp:copyright="Creative Commons BY-NC-SA 3" -thumbnailimage= -overwrite_original -preserve');
				//exec('exiftool "-filemodifydate<CreateDate" '.$dir.$file);

				$sql = 'UPDATE attachments SET created_on = "'.date('Y-m-d H:i:s', strtotime($date[0])).'",
				                               filesize = "'.filesize($dir.$file).'", digest = "'.md5_file($dir.$file).'"
				        WHERE disk_filename = "'.$file.'"';
			}
			else {
				$sql = 'UPDATE attachments SET filesize = "'.filesize($dir.$file).'", digest = "'.md5_file($dir.$file).'"
				        WHERE disk_filename = "'.$file.'"';
			}

			mysqli_query($db, $sql);
			echo $file,"\n";
		}
	}

	closedir($handle);
}

mysqli_close($db);
