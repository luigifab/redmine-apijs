# encoding: utf-8
# Created V/27/12/2013
# Updated D/03/05/2020
#
# Copyright 2008-2020 | Fabrice Creuzot (luigifab) <code~luigifab~fr>
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

module AttachmentPatch

  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do
      unloadable
      if Rails::VERSION::MAJOR >= 3
        include Rails.application.routes.url_helpers
      else
        include ActionController::UrlWriter
      end
      if Rails::VERSION::MAJOR >= 4
        before_create :update_date
      else
        before_save :update_date
      end
      after_destroy :delete_cache
    end
  end

  module InstanceMethods

    # https://www.redmine.org/issues/19024 pour l'éventuel préfixe avec Redmine 2
    def getUrl(action, all=false)
      if action == 'redmineshow'
        return getSuburi(url_for({only_path: true, controller: 'attachments', action: 'show', id: self.id, filename: self.filename}))
      elsif all
        return getSuburi(url_for({only_path: true, controller: 'apijs', action: action, id: self.id, filename: self.filename}))
      else
        return getSuburi(url_for({only_path: true, controller: 'apijs', action: action}))
      end
    end

    def getSuburi(url)
      if Redmine::VERSION::MAJOR == 2
        baseurl = Redmine::Utils.relative_url_root
        if not baseurl.blank? and not url.match(/^#{baseurl}/)
          url = baseurl + url
        end
      end
      return url
    end

    # liens
    def getShowUrl
      return getUrl('show', true)
    end

    def getThumbUrl
      return getUrl('thumb', true)
    end

    def getDownloadUrl
      return getUrl('download', true)
    end

    def getDownloadButton
      return "self.location.href = '" + getUrl('download', true) + "';"
    end

    def getEditButton(token)
      return "apijsRedmine.editAttachment(" + self.id.to_s + ", '" + getUrl('editdesc') + "', '" + token + "');"
    end

    def getDeleteButton(token)
      return "apijsRedmine.deleteAttachment(" + self.id.to_s + ", '" + getUrl('delete') + "', '" + token + "');"
    end

    def getShowButton(setting_show_filename, setting_show_exifdate, description)
      if self.isImage?
        return "apijs.dialog.dialogPhoto('" + self.getShowUrl + "', '" + ((setting_show_filename) ? self.filename : 'false') + "', '" + ((setting_show_exifdate) ? format_time(self.created_on) : 'false') + "', '" + description + "');"
      elsif self.isVideo?
        return "apijs.dialog.dialogVideo('" + self.getDownloadUrl + "', '" + ((setting_show_filename) ? self.filename : 'false') + "', '" + ((setting_show_exifdate) ? format_time(self.created_on) : 'false') + "', '" + description + "');"
      elsif self.is_text?
        return "self.location.href = '" + getUrl('redmineshow', false) + "';"
      end
    end

    # image, photo, vidéo
    def isImage?
      return self.filename =~ /\.(jpg|jpeg|png|svg)$/i
    end

    def isPhoto?
      types = []
      types.push('jpeg') if Setting.plugin_redmine_apijs['album_mimetype_jpeg'] == '1'
      types.push('jpg')  if Setting.plugin_redmine_apijs['album_mimetype_jpg']  == '1'
      types.push('png')  if Setting.plugin_redmine_apijs['album_mimetype_png']  == '1'
      types.push('pdf')  if Setting.plugin_redmine_apijs['album_mimetype_pdf']  == '1'
      types.push('psd')  if Setting.plugin_redmine_apijs['album_mimetype_psd']  == '1'
      types.push('eps')  if Setting.plugin_redmine_apijs['album_mimetype_eps']  == '1'
      types.push('tif')  if Setting.plugin_redmine_apijs['album_mimetype_tiff'] == '1'
      types.push('tiff') if Setting.plugin_redmine_apijs['album_mimetype_tiff'] == '1'
      return self.filename =~ /\.(#{types.join('|')})$/i
    end

    def isVideo?
      types = []
      types.push('ogv')  if Setting.plugin_redmine_apijs['album_mimetype_ogv']  == '1'
      types.push('webm') if Setting.plugin_redmine_apijs['album_mimetype_webm'] == '1'
      types.push('mp4')  if Setting.plugin_redmine_apijs['album_mimetype_mp4']  == '1'
      types.push('m4v')  if Setting.plugin_redmine_apijs['album_mimetype_m4v']  == '1'
      return self.filename =~ /\.(#{types.join('|')})$/i
    end

    # commande python
    def getCmd(source, target, width, height)
      cmd = `command -v python3 || command -v python || command -v python2`.strip!
      script = File.dirname(__FILE__).gsub('lib', 'tools/image.py')
      return cmd + ' ' + script.to_s + ' ' + source.to_s + ' ' + target.to_s + ' ' + width.to_s + ' ' + height.to_s + ' 2>&1'
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

      img_thumb = File.extname(self.filename).downcase == '.png' ? '.png' : '.jpg'
      img_thumb = File.join(APIJS_ROOT, 'thumb', self.created_on.strftime('%Y-%m').to_s, self.id.to_s + img_thumb)
      File.delete(img_thumb) if File.file?(img_thumb)

      img_show = File.extname(self.filename).downcase == '.png' ? '.png' : '.jpg'
      img_show = File.join(APIJS_ROOT, 'show', self.created_on.strftime('%Y-%m').to_s, self.id.to_s + img_show)
      File.delete(img_show) if File.file?(img_show)
    end

    # lecture de la date exif et mise à jour de la date de création
    # uniquement lors de la création d'une pièce jointe photo ou vidéo
    # utilise la commande exiftool (libimage-exiftool-perl)
    def update_date

      if new_record? && (self.isPhoto? || self.isVideo?) && self.readable?

        cmd    = 'exiftool -FastScan -IgnoreMinorErrors -DateTimeOriginal -S3 ' + self.diskfile + ' 2>&1'
        result = `#{cmd}`.gsub(/^\s+|\s+$/, '')

        logger.info 'APIJS::AttachmentPatch#update_date: ' + cmd + ' (' + result + ')'

        # 2014:06:14 16:43:53 (utilise le fuseau horaire de l'utilisateur)
        if result.length >= 19

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
      logger.info 'APIJS::AttachmentPatch#update_filedir: moving file from ' + src + ' to ' + dest
    end

    # recherche du type mime avec la commande file
    def getMimeType

        if self.readable? && self.content_type.blank?

          cmd    = 'file --brief --mime-type ' + self.diskfile + ' 2>&1'
          result = `#{cmd}`.gsub(/^\s+|\s+$/, '')
          logger.info 'APIJS::AttachmentPatch#getMimeType: ' + cmd + ' (' + result + ')'

          self.content_type = (result.length > 0) ? result : 'file/unknown'
          self.save!
        end

        return self.content_type
    end

  end
end

Attachment.send(:include, AttachmentPatch)