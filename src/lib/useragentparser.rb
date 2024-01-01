# encoding: utf-8
#
# Copyright 2013-2023 | Jesse G. Donat <donatj~gmail~com>
# https://github.com/donatj/PhpUserAgent
#
# Copyright 2019-2023 | Fabrice Creuzot (luigifab) <code~luigifab~fr>
# https://gist.github.com/luigifab/19a68d9aa98fa80f2961809d7cec59c0 (1.8.0-fork2)
#
# Parses a user agent string into its important parts
# Licensed under the MIT License
#

class Useragentparser

	def parse(userAgent=nil)

		userAgent = Thread.current[:request].env['HTTP_USER_AGENT'] unless userAgent

		platform = nil
		browser  = nil
		version  = nil
		empty    = {'platform' => platform, 'browser' => browser, 'version' => version}
		priority = ['Xbox One', 'Xbox', 'Windows Phone', 'Tizen', 'Android', 'FreeBSD', 'NetBSD', 'OpenBSD', 'CrOS', 'X11', 'Sailfish']

		return empty unless userAgent

		if (parentMatches = userAgent.match(/\((.*?)\)/m))
			result = parentMatches[1].scan(
				/(?<platform>BB\d+;|Android|Adr|Symbian|Sailfish|CrOS|Tizen|iPhone|iPad|iPod|Linux|(?:Open|Net|Free)BSD|Macintosh|Windows(?:\ Phone)?|Silk|linux-gnu|BlackBerry|PlayBook|X11|(?:New\ )?Nintendo\ (?:WiiU?|3?DS|Switch)|Xbox(?:\ One)?) (?:\ [^;]*)? (?:;|$)/imx
			).map(&:join)
			result.uniq!
			if result.length > 1
				if (keys = priority & result).length > 0
					platform = keys.first
				else
					platform = result[0]
				end
			elsif result
				platform = result[0]
			end
		end

		if platform == 'linux-gnu' || platform == 'X11'
			platform = 'Linux'
		elsif platform == 'CrOS'
			platform = 'Chrome OS'
		elsif platform == 'Adr'
			platform = 'Android'
		elsif !platform
			result = userAgent.to_enum(:scan,
				/(?<platform>Android)[:\/ ]/ix
			).map { Regexp.last_match.names.collect{ |x| {x => $~[x]} }.reduce({}, :merge) }
			 .reduce({}) { |h,pairs| pairs.each {|k,v| (h[k] ||= []) << v}; h }
			if result.length > 0
				platform = result['platform'].shift
			end
		end

		result = userAgent.to_enum(:scan, # ["browser" => ["Firefox"...], "version" => ["45.0"...]]
			/(?<browser>Camino|Kindle(\ Fire)?|Firefox|Thunderbird|Iceweasel|IceCat|Safari|MSIE|Trident|AppleWebKit|TizenBrowser|(?:Headless)?Chrome|YaBrowser|Vivaldi|IEMobile|Opera|OPR|Silk|Midori|(?-i:Edge)|EdgA?|CriOS|UCBrowser|Puffin|OculusBrowser|SamsungBrowser|SailfishBrowser|XiaoMi\/MiuiBrowser|YaApp_Android|Baiduspider|Applebot|Facebot|Googlebot|YandexBot|bingbot|Lynx|Version|Wget|curl|Valve\ Steam\ Tenfoot|NintendoBrowser|PLAYSTATION\ (?:\d|Vita)+)\)?;?(?:[\/ :](?<version>[\dA-Z.]+)|\/[A-Z]*)/ix
		).map { Regexp.last_match.names.collect{ |x| {x => $~[x]} }.reduce({}, :merge) }
		 .reduce({}) { |h,pairs| pairs.each {|k,v| (h[k] ||= []) << v}; h }

		# If nothing matched, return nil (to avoid undefined index errors)
		if !result['browser'] || !result['browser'][0] || !result['version'] || !result['version'][0]
			result = userAgent.match(/^(?!Mozilla)(?<browser>[A-Z\d\-]+)([\/ :](?<version>[\dA-Z.]+))?/ix)
			if result
				return {
					'platform' => platform ? platform : nil,
					'browser'  => result['browser'],
					'version'  => result['version'] ? result['version'] : nil
				}
			end
			return empty
		end

		rv_result = userAgent.match(/rv:(?<version>[\dA-Z.]+)/i)
		if rv_result && rv_result['version']
			rv_result = rv_result['version']
		end

		browser = result['browser'][0]
		version = result['version'][0]

		lowerBrowser = result['browser'].map(&:downcase)
		refkey = [0]
		refbro = [browser]
		refpla = [platform]
		refval = ['']

		if findt(lowerBrowser, {'OPR' => 'Opera', 'Facebot' => 'iMessageBot', 'UCBrowser' => 'UC Browser', 'YaBrowser' => 'Yandex', 'YaApp_Android' => 'Yandex', 'Iceweasel' => 'Firefox', 'Icecat' => 'Firefox', 'CriOS' => 'Chrome', 'Edg' => 'Edge', 'EdgA' => 'Edge', 'XiaoMi/MiuiBrowser' => 'MiuiBrowser'}, refkey, refbro)
			browser = refbro[0]
			version = result['version'][refkey[0]][0] =~ /\d/ ? result['version'][refkey[0]] : nil
		elsif find(lowerBrowser, 'Playstation Vita', refkey, platform)
			platform = 'PlayStation Vita'
			browser  = 'Browser'
		elsif find(lowerBrowser, ['Kindle Fire', 'Silk'], refkey, refval)
			browser  = refval[0] == 'Silk' ? 'Silk' : 'Kindle'
			platform = 'Kindle Fire'
			if !(version = result['version'][refkey[0]]) || !(version[0] =~ /\d/ ? true : false)
				version = result['version'][result['browser'].index('Version')]
			end
		elsif platform == 'Nintendo 3DS' || find(lowerBrowser, 'NintendoBrowser', refkey)
			browser = 'NintendoBrowser'
			version = result['version'][refkey[0]]
		elsif find(lowerBrowser, 'Kindle', refkey, refpla)
			browser  = result['browser'][refkey[0]]
			version  = result['version'][refkey[0]]
			platform = refpla[0]
		elsif find(lowerBrowser, 'Opera', refkey, refbro)
			find(lowerBrowser, 'Version', refkey)
			version = result['version'][refkey[0]]
			browser = refbro[0]
		elsif find(lowerBrowser, 'Puffin', refkey, refbro)
			version = result['version'][refkey[0]]
			browser = refbro[0]
			if version.length > 3
				part = version[-2..-1]
				if part == part.upcase
					version = version[0..-3]
					flags = {'IP' => 'iPhone', 'IT' => 'iPad', 'AP' => 'Android', 'AT' => 'Android', 'WP' => 'Windows Phone', 'WT' => 'Windows'}
					if flags[part] != nil
						platform = flags[part]
					end
				end
			end
		elsif find(lowerBrowser, ['Applebot', 'IEMobile', 'Edge', 'Midori', 'Vivaldi', 'OculusBrowser', 'SamsungBrowser', 'Valve Steam Tenfoot', 'Chrome', 'HeadlessChrome', 'SailfishBrowser'], refkey, refbro)
			version = result['version'][refkey[0]]
			browser = refbro[0]
		elsif rv_result && find(lowerBrowser, 'Trident')
			browser = 'MSIE'
			version = rv_result
		elsif browser == 'AppleWebKit'
			if platform == 'Android'
				browser = 'Android Browser'
			elsif platform && platform.index('BB') === 0
				browser  = 'BlackBerry Browser'
				platform = 'BlackBerry'
			elsif platform == 'BlackBerry' || platform == 'PlayBook'
				browser = 'BlackBerry Browser'
			elsif find(lowerBrowser, 'Safari', refkey, refbro) || find(lowerBrowser, 'TizenBrowser', refkey, refbro)
				browser = refbro[0]
			end
			find(lowerBrowser, 'Version', refkey)
			version = result['version'][refkey[0]]
		else
			pKey = result['browser'].grep(/playstation \d/i)
			if pKey.length > 0
				pKey = pKey.first
				platform = 'PlayStation ' + pKey.gsub(/\D/, '')
				browser  = 'NetFront'
			end
		end

		return {'platform' => platform ? platform : nil, 'browser' => browser ? browser : nil, 'version' => version ? version : nil}
	end

	def find(lowerBrowser, search, key=[], value=[])

		search = Array(search)

		search.each { |val|
			xkey = lowerBrowser.index(val.downcase)
			if xkey != nil
				value[0] = val if value
				key[0] = xkey
				return true
			end
		}

		return false
	end

	def findt(lowerBrowser, search, key=nil, value=nil)

		refval = ['']

		if find(lowerBrowser, search.keys, key, refval)
			value[0] = search[refval[0]]
			return true
		end

		return false
	end
end