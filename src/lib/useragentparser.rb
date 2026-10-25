# encoding: utf-8
#
# Copyright 2013-2026 | Jesse G. Donat <donatj~gmail~com>
# https://github.com/donatj/PhpUserAgent
#
# Copyright 2019-2026 | Fabrice Creuzot (luigifab) <code~luigifab~fr>
# https://gist.github.com/luigifab/19a68d9aa98fa80f2961809d7cec59c0 (1.12.0-fork1)
#
# Parses a user agent string into its important parts
# Fork compared/updated by Claude from the original
# Licensed under the MIT License
#

class Useragentparser

	def parse(userAgent=nil)

		userAgent = Thread.current[:request].env['HTTP_USER_AGENT'] unless userAgent

		platform = nil
		browser  = nil
		version  = nil
		empty    = {'platform' => platform, 'browser' => browser, 'version' => version}
		priority = ['Xbox One','Xbox','Windows Phone','Tizen','Android','FreeBSD','NetBSD','OpenBSD','CrOS','Fuchsia','X11','Sailfish']

		return empty if !userAgent || userAgent == '' || userAgent == '0'
		encoding, userAgent = userAgent.encoding, userAgent.dup.force_encoding('BINARY')
		if (parentMatches = userAgent.match(/\((.*?)\)/))
			result = parentMatches[1].scan(
				/(?<platform>BB\d+;|Android|Adr|Symbian|Sailfish|CrOS|Fuchsia|Tizen|iPhone|iPad|iPod|Linux|(?:Open|Net|Free)BSD|Macintosh|Windows(?:\ Phone)?|Silk|linux-gnu|BlackBerry|PlayBook|X11|(?:New\ )?Nintendo\ (?:WiiU?|3?DS|Switch)|Xbox(?:\ One)?) (?:\ [^;]*)? (?:;|$)/imx
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
			/(?<prev>.)?(?<browser>Camino|Kindle(\ Fire)?|Firefox|Thunderbird|Iceweasel|IceCat|Safari|MSIE|Trident|AppleWebKit|TizenBrowser|(?:Headless)?Chrome|YaBrowser|Vivaldi|IEMobile|Opera|OPR|Silk|Midori|(?-i:Edge)|EdgA?|CriOS|UCBrowser|Puffin|OculusBrowser|SamsungBrowser|SailfishBrowser|XiaoMi\/MiuiBrowser|YaApp_Android|Whale|Applebot|Facebot|Googlebot|YandexBot|bingbot|Lynx|Version|Valve\ Steam\ Tenfoot|Mastodon|NintendoBrowser|PLAYSTATION\ (?:\d|Vita)+)\)?;?(?:[\/ :](?<version>[\dA-Z.]+)|\/[A-Z]*)/ix
		).map { Regexp.last_match.names.collect{ |x| {x => $~[x].to_s} }.reduce({}, :merge) }
		 .reduce({}) { |h,pairs| pairs.each {|k,v| (h[k] ||= []) << v}; h }

		# If nothing matched, check for simple bot patterns
		if !result['browser'] || !result['browser'][0]
			# Try: bot/version with contact info "site.com botname/1.0 (+contact)"
			if (gr = userAgent.match(/(?<browser>[A-Z\d\-]+)[\/ ](?<version>[\dA-Z.]+)\s*\(\+(?:https?:|[a-z\d._-]+@[a-z\d._-]+)/ix))
				return {'platform' => platform, 'browser' => gr['browser'], 'version' => gr['version']}
			end
			# Try: simple bot at start "BotName/version" (not Mozilla)
			if (gr = userAgent.match(/\A(?!Mozilla)(?<browser>[A-Z\d\-]+)([\/ :](?<version>[\dA-Z.]+))?/ix))
				return {'platform' => platform, 'browser' => gr['browser'], 'version' => (gr['version'] && gr['version'] != '0') ? gr['version'] : nil}
			end
		end

		if (!result['browser'] || !result['browser'][0] || result['prev'][0] != '') &&
		   (bot_result = userAgent.match(/[(;]\s*(?<browser>[^(\/;]+)(?:[:\/ ]v?(?<version>[\dA-Z.]+)[^;)\s]*)?;?(?:\s*robot;)?\s*\+(?:https?:|[a-z\d._-]+@[a-z\d._-]+)/ix))
			return {'platform' => platform, 'browser' => bot_result['browser'].strip.force_encoding(encoding), 'version' => (bot_result['version'] && bot_result['version'] != '0') ? bot_result['version'] : nil}
		end

		if !result['browser'] || !result['browser'][0]
			return {'platform' => platform, 'browser' => nil, 'version' => nil}
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
			version = result['version'][refkey[0]].to_s =~ /\A\d/ ? result['version'][refkey[0]] : nil
		elsif find(lowerBrowser, 'Playstation Vita', refkey)
			platform = 'PlayStation Vita'
			browser  = 'Browser'
		elsif find(lowerBrowser, ['Kindle Fire', 'Silk'], refkey, refval)
			browser  = refval[0] == 'Silk' ? 'Silk' : 'Kindle'
			platform = 'Kindle Fire'
			if !(version = result['version'][refkey[0]]) || version == '0' || !(version[0] =~ /\d/ ? true : false)
				version = result['version'][result['browser'].index('Version') || 0]
			end
		elsif find(lowerBrowser, 'NintendoBrowser', refkey) || platform == 'Nintendo 3DS'
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
			if version && version.length > 3
				part = version[-2..-1]
				if part =~ /\A[A-Z]{2}\z/
					version = version[0..-3]
					flags = {'IP' => 'iPhone','IT' => 'iPad','AP' => 'Android','AT' => 'Android','WP' => 'Windows Phone','WT' => 'Windows'}
					if flags[part] != nil
						platform = flags[part]
					end
				end
			end
		elsif find(lowerBrowser, ['Googlebot', 'Applebot', 'IEMobile', 'Edge', 'Midori', 'Whale', 'Vivaldi', 'OculusBrowser', 'SamsungBrowser', 'Valve Steam Tenfoot', 'Chrome', 'HeadlessChrome', 'SailfishBrowser'], refkey, refbro)
			version = result['version'][refkey[0]]
			browser = refbro[0]
		elsif rv_result && rv_result != '0' && find(lowerBrowser, 'Trident')
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
				version = result['version'][refkey[0]]
			elsif result['browser'].length > 0
				key     = result['browser'].length - 1;
				browser = result['browser'][key];
				version = result['version'][key];
			end
			if find(lowerBrowser, 'Version', refkey)
				version = result['version'][refkey[0]]
			end
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