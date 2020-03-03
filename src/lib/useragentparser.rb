# encoding: utf-8
#
# https://github.com/donatj/PhpUserAgent 0.15.1
# Parses a user agent string into its important parts
# Licensed under the MIT License
# PHP  by Jesse G. Donat <donatj~gmail~com> 2013-2019
# Ruby by Fabrice Creuzot (luigifab) <code~luigifab~fr> 2019

class Useragentparser

	def parse(userAgent=nil)

		unless userAgent
			userAgent = Thread.current[:request].env['HTTP_USER_AGENT']
		end

		platform = nil
		browser  = nil
		version  = nil
		empty    = { 'platform' => platform, 'browser' => browser, 'version' => version }
		priority = ['Xbox One', 'Xbox', 'Windows Phone', 'Tizen', 'Android', 'FreeBSD', 'NetBSD', 'OpenBSD', 'CrOS', 'X11']

		return empty unless userAgent

		if parentMatches = userAgent.match(/\((.*?)\)/m)
			result = parentMatches[1].scan(
				/(?<platform>BB\d+;|Android|CrOS|Tizen|iPhone|iPad|iPod|Linux|(Open|Net|Free)BSD|Macintosh|Windows(\ Phone)?|Silk|linux-gnu|BlackBerry|PlayBook|X11|(New\ )?Nintendo\ (WiiU?|3?DS|Switch)|Xbox(\ One)?) (?:\ [^;]*)? (?:;|$)/imx
			).map(&:join)
			result.uniq!
			if (result.length > 1)
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
		end

		result = userAgent.to_enum(:scan, # ["browser" => ["Firefox"...], "version" => ["45.0"...]]
			/(?<browser>Camino|Kindle(\ Fire)?|Firefox|Iceweasel|IceCat|Safari|MSIE|Trident|AppleWebKit|TizenBrowser|(?:Headless)?Chrome|YaBrowser|Vivaldi|IEMobile|Opera|OPR|Silk|Midori|Edge|Edg|CriOS|UCBrowser|Puffin|OculusBrowser|SamsungBrowser|Baiduspider|Googlebot|YandexBot|bingbot|Lynx|Version|Wget|curl|Valve\ Steam\ Tenfoot|NintendoBrowser|PLAYSTATION\ (\d|Vita)+) (?:\)?;?) (?:(?:[:\/ ])(?<version>[0-9A-Z.]+)|\/(?:[A-Z]*))/ix
		).map { Regexp.last_match.names.collect{ |x| {x => $~[x]} }.reduce({}, :merge) }
		 .reduce({}) { |h,pairs| pairs.each {|k,v| (h[k] ||= []) << v}; h }

		# If nothing matched, return nil (to avoid undefined index errors)
		if !result['browser'] || !result['browser'][0] || !result['version'] || !result['version'][0]
			result = userAgent.match(/^(?!Mozilla)(?<browser>[A-Z0-9\-]+)(\/(?<version>[0-9A-Z.]+))?/ix)
			if result
				return {
					'platform' => platform ? platform : nil,
					'browser'  => result['browser'],
					'version'  => result['version'] ? result['version'] : nil
				}
			end

			return empty
		end

		rv_result = userAgent.match(/rv:(?<version>[0-9A-Z.]+)/i)
		if rv_result && rv_result['version']
			rv_result = rv_result['version']
		end

		browser = result['browser'][0]
		version = result['version'][0]

		lowerBrowser = result['browser'].map(&:downcase)
		key = [0]
		val = ''
		if browser == 'Iceweasel' || browser.downcase == 'icecat'
			browser = 'Firefox'
		elsif find(lowerBrowser, 'Playstation Vita', key)
			platform = 'PlayStation Vita'
			browser  = 'Browser'
		elsif find(lowerBrowser, ['Kindle Fire', 'Silk'], key, val)
			browser  = val == 'Silk' ? 'Silk' : 'Kindle'
			platform = 'Kindle Fire'
			if !(version = result['version'][key[0]]) || !(version[0] =~ /[0-9]/ ? true : false)
				version = result['version'][ result['browser'].index('Version') ]
			end
		elsif platform == 'Nintendo 3DS' || find(lowerBrowser, 'NintendoBrowser', key)
			browser = 'NintendoBrowser'
			version = result['version'][key[0]]
		elsif find(lowerBrowser, 'Kindle', key, platform)
			browser = result['browser'][key[0]]
			version = result['version'][key[0]]
		elsif find(lowerBrowser, 'OPR', key)
			browser = 'Opera'
			version = result['version'][key[0]]
		elsif find(lowerBrowser, 'Opera', key, browser)
			find(lowerBrowser, 'Version', key)
			version = result['version'][key[0]]
		elsif find(lowerBrowser, 'Puffin', key, browser)
			version = result['version'][key[0]]
			if version.length > 3
				part = version[-2..-1]
				if part == part.upcase
					version = version[0..-3]
					flags = { 'IP' => 'iPhone', 'IT' => 'iPad', 'AP' => 'Android', 'AT' => 'Android', 'WP' => 'Windows Phone', 'WT' => 'Windows' }
					if flags[part] != nil
						platform = flags[part]
					end
				end
			end
		elsif find(lowerBrowser, 'YaBrowser', key, browser)
			browser = 'Yandex'
			version = result['version'][key[0]]
		elsif find(lowerBrowser, ['Edge', 'Edg'], key, browser)
			browser = 'Edge'
			version = result['version'][key[0]]
		elsif find(lowerBrowser, ['IEMobile', 'Midori', 'Vivaldi', 'OculusBrowser', 'SamsungBrowser', 'Valve Steam Tenfoot', 'Chrome', 'HeadlessChrome'], key, browser)
			version = result['version'][key[0]]
		elsif rv_result && find(lowerBrowser, 'Trident', key)
			browser = 'MSIE'
			version = rv_result
		elsif find(lowerBrowser, 'UCBrowser', key)
			browser = 'UC Browser'
			version = result['version'][key[0]]
		elsif find(lowerBrowser, 'CriOS', key)
			browser = 'Chrome'
			version = result['version'][key[0]]
		elsif browser == 'AppleWebKit'
			if platform == 'Android'
				browser = 'Android Browser'
			elsif platform.index('BB') === 0
				browser  = 'BlackBerry Browser'
				platform = 'BlackBerry'
			elsif platform == 'BlackBerry' || platform == 'PlayBook'
				browser = 'BlackBerry Browser'
			else
				find(lowerBrowser, 'Safari', key, browser) || find(lowerBrowser, 'TizenBrowser', key, browser)
			end
			find(lowerBrowser, 'Version', key)
			version = result['version'][key[0]]
		else
			pKey = result['browser'].grep(/playstation \d/i)
			if pKey.length > 0
				pKey = pKey.first
				platform = 'PlayStation ' + pKey.gsub(/\D/, '')
				browser  = 'NetFront'
			end
		end

		return { 'platform' => platform ? platform : nil, 'browser' => browser ? browser : nil, 'version' => version ? version : nil }
	end

	def find(lowerBrowser, search, key, value=nil)

		search = Array(search)
		value  = String(value)

		for val in search
			xkey = lowerBrowser.index(val.downcase)
			if xkey != nil
				value.slice! value
				value << val
				key[0] = xkey
				return true
			end
		end

		return false
	end
end