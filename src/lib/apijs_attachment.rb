# encoding: utf-8
# Created V/27/12/2013
# Updated D/01/11/2026
#
# Copyright 2008-2027 | Fabrice Creuzot (luigifab) <code~luigifab~fr>
# https://github.com/luigifab/redmine-apijs
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

require 'open3'

module ApijsAttachment

  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do
      if Rails::VERSION::MAJOR < 7
        unloadable
      end
      if Rails::VERSION::MAJOR >= 3
        include Rails.application.routes.url_helpers
        before_create :update_date
      else
        include ActionController::UrlWriter
        before_save :update_date
      end
      after_destroy :delete_cache
    end
  end

  module InstanceMethods

    # https://www.redmine.org/issues/19024
    # Examples for the attachment 42 named photo.jpg:
    #  getUrl('redmineshow') → /attachments/42/photo.jpg
    #  getUrl('thumb')       → /apijs/preview/thumb/42/photo.jpg
    #  getUrl('srcset')      → /apijs/preview/srcset/42/photo.jpg
    #  getUrl('show')        → /apijs/preview/show/42/photo.jpg
    #  getUrl('download')    → /apijs/download/42/photo.jpg
    #  getUrl('desc')        → /apijs/edit/desc
    #  getUrl('name')        → /apijs/edit/name
    #  getUrl('delete')      → /apijs/delete
    # For a svg file, thumb, srcset and show give the same url: /apijs/preview/show/42/drawing.svg
    # The file name is encoded: /apijs/download/42/my%20photo%20(1).jpg
    # When Redmine is in a sub directory (relative_url_root), the url starts with it
    def getUrl(action)
      if action == 'redmineshow'
        return self.getSuburi(url_for({only_path: true, controller: 'attachments', action: 'show', id: self.id, filename: self.filename}))
      end
      if ['thumb', 'srcset', 'show'].include?(action)
        type = (self.filename =~ /\.svg$/i) ? 'show' : action
        return self.getSuburi(url_for({only_path: true, controller: 'apijs', action: 'preview', id: self.id, filename: self.filename, type: type}))
      end
      if ['desc', 'name'].include?(action)
        return self.getSuburi(url_for({only_path: true, controller: 'apijs', action: 'edit', type: action}))
      end
      if action == 'download'
        return self.getSuburi(url_for({only_path: true, controller: 'apijs', action: 'download', id: self.id, filename: self.filename}))
      end
      return self.getSuburi(url_for({only_path: true, controller: 'apijs', action: action}))
    end

    def getSuburi(url)
      if Redmine::VERSION::MAJOR >= 2
        baseurl = Redmine::Utils.relative_url_root
        if not baseurl.blank? and not url.match(/^#{baseurl}/)
          url = baseurl + url
        end
      end
      return url
    end

    # links
    def getOnclick(type, token)
      return "apijsRedmine." + type + "Attachment(this, " + self.id.to_s + ", '" + self.getUrl(type) + "', '" + token + "');"
    end

    # paths
    def getPreviewPath(type)
      return File.join(APIJS_ROOT, type, self.created_on.strftime('%Y-%m').to_s, self.id.to_s + self.getPreviewExt)
    end

    # photo or video
    def getMimeType(name=nil)
      types = {
        'jpg'  => 'image/jpeg',
        'jpeg' => 'image/jpeg',
        'gif'  => 'image/gif',
        'png'  => 'image/png',
        'webp' => 'image/webp',
        'svg'  => 'image/svg+xml',
        'ogv'  => 'video/ogg',
        'webm' => 'video/webm',
        'mp4'  => 'video/mp4',
        'pdf'  => 'application/pdf'
      }
      return types[File.extname(name || self.filename).downcase.delete('.')] || 'application/octet-stream'
    end

    def isPhoto?
      types = []
      types.push('jpg')  if Setting.plugin_redmine_apijs['album_mimetype_jpg']  == '1'
      types.push('jpeg') if Setting.plugin_redmine_apijs['album_mimetype_jpeg'] == '1'
      types.push('gif')  if Setting.plugin_redmine_apijs['album_mimetype_gif']  == '1'
      types.push('png')  if Setting.plugin_redmine_apijs['album_mimetype_png']  == '1'
      types.push('tif')  if Setting.plugin_redmine_apijs['album_mimetype_tif']  == '1'
      types.push('tiff') if Setting.plugin_redmine_apijs['album_mimetype_tiff'] == '1'
      types.push('webp') if Setting.plugin_redmine_apijs['album_mimetype_webp'] == '1'
      types.push('bmp')  if Setting.plugin_redmine_apijs['album_mimetype_bmp']  == '1'
      types.push('eps')  if Setting.plugin_redmine_apijs['album_mimetype_eps']  == '1'
      types.push('psd')  if Setting.plugin_redmine_apijs['album_mimetype_psd']  == '1'
      types.push('svg')  if Setting.plugin_redmine_apijs['album_mimetype_svg']  == '1'
      return false       if types.empty?
      return self.filename =~ /\.(#{types.join('|')})$/i
    end

    def isVideo?
      types = []
      types.push('ogv')  if Setting.plugin_redmine_apijs['album_mimetype_ogv']  == '1'
      types.push('webm') if Setting.plugin_redmine_apijs['album_mimetype_webm'] == '1'
      types.push('mp4')  if Setting.plugin_redmine_apijs['album_mimetype_mp4']  == '1'
      return false       if types.empty?
      return self.filename =~ /\.(#{types.join('|')})$/i
    end

    def isPdf?
      return self.filename =~ /\.pdf$/i
    end

    # extension of the generated images
    def getPreviewExt
        ext = File.extname(self.filename).downcase
        return ext if ext == '.gif'
        return ext if ext == '.png'
        return ext if ext == '.webp'
        return ext if ext == '.svg'
        return '.jpg'
    end

    # python command
    def getPython

      return @cmd if defined? @cmd

      if Redmine::Platform.mswin?
        cmd = `python.exe --version`
        if $? == 0
          cmd = 'python.exe'
        else
          cmd = `python --version`
          if $? == 0
            cmd = 'python'
          else
            cmd = nil
          end
        end
      else
        cmd = `python3 --version`
        if $? == 0
          cmd = 'python3'
        else
          cmd = nil
        end
      end

      @cmd = cmd
      return cmd
    end

    def getCmd(source, target, width, height, fixed=false)

      cmd = getPython
      cmd = 'notfound' if not cmd or cmd.length == 0

      script = File.join(File.dirname(__FILE__), 'image.py')
      return [cmd, script.to_s, source.to_s, target.to_s, width.to_s, height.to_s, '90'] + (fixed ? ['fixed'] : [])
    end

    # run without a shell, output and errors together
    def runCmd(cmd)
      return Open3.capture2e(*cmd)[0].gsub(/^\s+|\s+$/, '')
    rescue SystemCallError => e
      return e.message
    end

    def createPreview(type)
      sizes  = {'thumb' => [200, 150, true], 'srcset' => [400, 300, true], 'show' => [1200, 900, false]}
      target = self.getPreviewPath(type)
      unless File.file?(target)
        cmd = self.getCmd(self.diskfile, target, *sizes[type])
        logger.info 'APIJS::ApijsAttachment#createPreview: ' + cmd.join(' ') + ' (' + self.runCmd(cmd) + ')'
      end
    end

    # exclusion
    def isExcluded?

      Setting.plugin_redmine_apijs['album_exclude_name'].split(',').each { |token|
        return true if (!self.filename.blank? && self.filename.index(token) == 0)
      }

      Setting.plugin_redmine_apijs['album_exclude_desc'].split(',').each { |token|
        return true if (!self.description.blank? && self.description.index(token) == 0)
      }

      return false
    end

    # remove the cached images
    def delete_cache
      ['thumb', 'srcset', 'show'].each { |type|
        img = self.getPreviewPath(type)
        File.delete(img) if File.file?(img)
      }
    end

    # read the exif date and update the creation date with exiftool (libimage-exiftool)
    def update_date

      if new_record? && (self.isPhoto? || self.isVideo?) && self.readable?

        cmd    = ['exiftool', '-FastScan', '-IgnoreMinorErrors', '-DateTimeOriginal', '-S3', self.diskfile]
        result = runCmd(cmd)

        logger.info 'APIJS::ApijsAttachment#update_date: ' + cmd.join(' ') + ' (' + result + ')'

        # 2014:06:14 16:43:53 (uses the user's time zone)
        if result =~ /^\d{4}.\d{2}.\d{2} \d{2}.\d{2}.\d{2}/

          date = result[0..9].gsub(':', '-') + ' ' + result[11..18]
          zone = User.current.time_zone
          date = zone ? zone.parse(date) : date

          self.created_on = date
          self.update_filedir!
        end
      end
    end

    # move the new file if it is not in the right directory
    def update_filedir!

      return self.disk_directory unless defined?

      src  = self.diskfile
      time = self.created_on || DateTime.now
      self.disk_directory = time.strftime("%Y/%m")
      dest = self.diskfile

      return if src == dest

      unless FileUtils.mkdir_p(File.dirname(dest))
        logger.error 'Could not create directory ' + File.dirname(dest)
        return
      end

      unless FileUtils.mv(src, dest)
        logger.error 'Could not move attachment from ' + src + ' to ' + dest
        return
      end

      update_column :disk_directory, self.disk_directory unless new_record?
      logger.info 'APIJS::ApijsAttachment#update_filedir: moving file from ' + src + ' to ' + dest
    end

    # information
    def getProgramVersions(helpPil, helpSco)

      cmd = getPython

      if not cmd or cmd.length == 0
        pyt = 'not found'
        pil = pyt
        sco = pyt
      else
        pyt = `#{cmd} --version 2>&1`.gsub('Python', '').strip!
        pyt = pyt.split(/\D/).slice(0, 3).join('.')

        version = lambda { |out|
          if out.include? "o module named"
            'not available'
          elsif out.include? "__version__"
            'available'
          else
            out.split(/\D/).slice(0, 3).join('.')
          end
        }

        pil = version.call(`#{cmd} -c "from PIL import Image; print(Image.__version__)" 2>&1`.strip!)
        sco = version.call(`#{cmd} -c "import scour; print(scour.__version__)" 2>&1`.strip!)
      end

      return sprintf('%s / %s %s / %s %s', pyt, pil, helpPil, sco, helpSco)
    end

  end
end

Attachment.send(:include, ApijsAttachment)