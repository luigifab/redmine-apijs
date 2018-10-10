<?php
/**
 * Created J/26/12/2013
 * Updated M/28/02/2017
 *
 * Copyright 2008-2018 | Fabrice Creuzot (luigifab) <code~luigifab~info>
 * https://www.luigifab.info/redmine/apijs
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
ini_set('display_errors', 1);

header('Content-Type: text/plain; charset=utf-8');
header('Cache-Control: no-cache, must-revalidate');
header('Pragma: no-cache');

$db = mysqli_connect('SERVER', 'USER', 'PASSWORD', 'DATABASE');
exec('find /THE_REDMINE_FILES_DIRECTORY/ -type f', $files);

foreach ($files as $file) {

	if (is_file($file)) {

		$jpg = (strpos($file, '.jpg') !== false) ? true : false;
		$date = null;

		if ($jpg) {
			exec('exiftool "-filemodifydate<CreateDate" '.$dir.$file);
			exec('exiftool -FastScan -IgnoreMinorErrors -DateTimeOriginal '.$dir.$file.' | cut -c35-', $date);
		}

		if ($jpg && !empty($date[0])) {
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

mysqli_close($db);