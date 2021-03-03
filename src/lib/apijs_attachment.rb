# encoding: utf-8
# Created V/27/12/2013
# Updated J/18/02/2021
#
# Copyright 2008-2021 | Fabrice Creuzot (luigifab) <code~luigifab~fr>
# https://www.luigifab.fr/redmine/apijs
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

module ApijsAttachment

  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do
      unloadable
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
    def getUrl(action, all=false)
      if action == 'redmineshow'
        return self.getSuburi(url_for({only_path: true, controller: 'attachments', action: 'show', id: self.id, filename: self.filename}))
      elsif all
        return self.getSuburi(url_for({only_path: true, controller: 'apijs', action: action, id: self.id, filename: self.filename}))
      else
        return self.getSuburi(url_for({only_path: true, controller: 'apijs', action: action}))
      end
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

    # liens
    def getShowUrl
      return self.getUrl('show', true)
    end

    def getThumbUrl
      return self.filename =~ /\.svg$/i ? self.getShowUrl : self.getUrl('thumb', true)
    end

    def getSrcsetUrl
      return self.filename =~ /\.svg$/i ? self.getShowUrl : self.getUrl('srcset', true)
    end

    def getDownloadUrl
      return self.getUrl('download', true)
    end

    def getDownloadButton
      return "self.location.href = '" + self.getUrl('download', true) + "';"
    end

    def getEditButton(token)
      return "apijsRedmine.editAttachment(this, " + self.id.to_s + ", '" + self.getUrl('editdesc') + "', '" + token + "');"
    end

    def getRenameButton(token)
      return "apijsRedmine.renameAttachment(this, " + self.id.to_s + ", '" + self.getUrl('editname') + "', '" + token + "');"
    end

    def getDeleteButton(token)
      return "apijsRedmine.removeAttachment(this, " + self.id.to_s + ", '" + self.getUrl('delete') + "', '" + token + "');"
    end

    def getShowButton(setting_show_filename, setting_show_exifdate, description)
      if self.isImage?
        return "apijs.dialog.dialogPhoto('" + self.getShowUrl + "', '" + (setting_show_filename ? self.filename : 'false') + "', '" + (setting_show_exifdate ? format_time(self.created_on) : 'false') + "', '" + description + "');"
      elsif self.isVideo?
        return "apijs.dialog.dialogVideo('" + self.getDownloadUrl + "', '" + (setting_show_filename ? self.filename : 'false') + "', '" + (setting_show_exifdate ? format_time(self.created_on) : 'false') + "', '" + description + "');"
      elsif self.is_text?
        return "self.location.href = '" + self.getUrl('redmineshow', false) + "';"
      end
    end

    # chemin
    def getImgThumb
        return File.join(APIJS_ROOT, 'thumb', self.created_on.strftime('%Y-%m').to_s, self.id.to_s + self.getExt)
    end

    def getImgSrcset
      return File.join(APIJS_ROOT, 'srcset', self.created_on.strftime('%Y-%m').to_s, self.id.to_s + self.getExt)
    end

    def getImgShow
      return File.join(APIJS_ROOT, 'show', self.created_on.strftime('%Y-%m').to_s, self.id.to_s + self.getExt)
    end

    # image, photo, vidéo
    def isImage?
      return self.filename =~ /\.(jpg|jpeg|gif|png|webp|svg)$/i
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
      return self.filename =~ /\.(#{types.join('|')})$/i
    end

    def isVideo?
      types = []
      types.push('ogv')  if Setting.plugin_redmine_apijs['album_mimetype_ogv']  == '1'
      types.push('webm') if Setting.plugin_redmine_apijs['album_mimetype_webm'] == '1'
      types.push('mp4')  if Setting.plugin_redmine_apijs['album_mimetype_mp4']  == '1'
      return self.filename =~ /\.(#{types.join('|')})$/i
    end

    # extension des images générées
    def getExt
        ext = File.extname(self.filename).downcase
        return ext if ext == '.gif'
        return ext if ext == '.png'
        return ext if ext == '.webp'
        return ext if ext == '.svg'
        return '.jpg'
    end

    # commande python
    def getPython

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

      return cmd
    end

    def getCmd(source, target, width, height, fixed=false)

      cmd = getPython
      cmd = 'notfound' if not cmd or cmd.length == 0

      script = File.join(File.dirname(__FILE__), (self.isPhoto? ? 'image.py' : 'video.py'))
      return cmd + ' ' + script.to_s + ' ' + source.to_s + ' ' + target.to_s + ' ' +
        width.to_s + ' ' + height.to_s + (fixed ? ' 90 fixed' : ' 90') + ' 2>&1'
    end

    # exclusion
    def isExcluded?

      names = Setting.plugin_redmine_apijs['album_exclude_name'].split(',')
      descs = Setting.plugin_redmine_apijs['album_exclude_desc'].split(',')

      unless names.empty?
        names.each { |token|
          return true if (!self.filename.blank? && self.filename.index(token) == 0)
        }
      end

      unless descs.empty?
        descs.each { |token|
          return true if (!self.description.blank? && self.description.index(token) == 0)
        }
      end

      return false
    end

    # supprime les images en cache
    def delete_cache

      img_thumb = self.getImgThumb
      File.delete(img_thumb) if File.file?(img_thumb)

      img_srcset = self.getImgSrcset
      File.delete(img_srcset) if File.file?(img_srcset)

      img_show = self.getImgShow
      File.delete(img_show) if File.file?(img_show)
    end

    # lecture de la date exif et maj de la date de création avec exiftool (libimage-exiftool)
    def update_date

      if new_record? && (self.isPhoto? || self.isVideo?) && self.readable?

        cmd    = 'exiftool -FastScan -IgnoreMinorErrors -DateTimeOriginal -S3 ' + self.diskfile + ' 2>&1'
        result = `#{cmd}`.gsub(/^\s+|\s+$/, '')

        logger.info 'APIJS::ApijsAttachment#update_date: ' + cmd + ' (' + result + ')'

        # 2014:06:14 16:43:53 (utilise le fuseau horaire de l'utilisateur)
        if result =~ /^[0-9]{4}.[0-9]{2}.[0-9]{2} [0-9]{2}.[0-9]{2}.[0-9]{2}/

          date = result[0..9].gsub(':', '-') + ' ' + result[11..18]
          zone = User.current.time_zone
          date = zone ? zone.parse(date) : date

          self.created_on = date
          self.update_filedir!
        end
      end
    end

    # déplace le nouveau fichier s'il n'est pas dans le bon dossier
    def update_filedir!

      return unless defined? self.disk_directory

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

    # informations
    def getProgramVersions(helpPil, helpSco)

      cmd = getPython

      if not cmd or cmd.length == 0
        pyt = 'not found'
        pil = pyt
        sco = pyt
      else
        pyt = `#{cmd} --version 2>&1`.gsub('Python', '').strip!
        pyt = pyt.split(/\D/).slice(0, 3).join('.')

        pil = `#{cmd} -c "from PIL import Image; print(Image.__version__)" 2>&1`.strip!
        if pil.include? "o module named"
          pil = 'not available'
        elsif pil.include? "__version__"
          pil = 'available'
        else
          pil = pil.split(/\D/).slice(0, 3).join('.')
        end

        sco = `#{cmd} -c "import scour; print(scour.__version__)" 2>&1`.strip!
        if sco.include? "o module named"
          sco = 'not available'
        elsif sco.include? "__version__"
          sco = 'available'
        else
          sco = sco.split(/\D/).slice(0, 3).join('.')
        end
      end

      return sprintf('%s / %s %s / %s %s', pyt, pil, helpPil, sco, helpSco)
    end

  end
end

Attachment.send(:include, ApijsAttachment)