# encoding: utf-8
# Created V/27/12/2013
# Updated V/30/12/2016
#
# Copyright 2008-2017 | Fabrice Creuzot (luigifab) <code~luigifab~info>
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

module AttachmentPatch

  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do
      unloadable
      # Redmine 2 et + (Rails 3)
      if Rails::VERSION::MAJOR >= 3
        include Rails.application.routes.url_helpers
      else
        include ActionController::UrlWriter
      end
      # Redmine 3 et + (Rails 4)
      if Rails::VERSION::MAJOR >= 4
        before_create :update_date
      else
        before_save :update_date
      end
    end
  end

  module InstanceMethods

    # construction des urls
    # https://www.redmine.org/issues/19024 pour l'éventuel préfixe avec Redmine 2 (Rails 3)
    def getUrl(action, all=false)
      if (action == 'redmineshow')
        return getSuburi(url_for({ :only_path => true, :controller=>'attachments', :action => 'show', :id => self.id, :filename => self.filename }))
      elsif all
        return getSuburi(url_for({ :only_path => true, :controller=>'apijs', :action => action, :id => self.id, :filename => self.filename }))
      else
        return getSuburi(url_for({ :only_path => true, :controller=>'apijs', :action => action }))
      end
    end

    def getSuburi(url)
      # Redmine 2 (Rails 3)
      if Rails::VERSION::MAJOR == 3
        baseurl = Redmine::Utils.relative_url_root
        if not baseurl.blank? and not url.match(/^#{baseurl}/)
          url = baseurl + url
        end
      end
      return url
    end

    # adresses dynamiques
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
      return "location.href = '" + getUrl('download', true) + "';"
    end

    def getEditButton(token)
      return "apijsEditAttachment(" + self.id.to_s + ", '" + getUrl('editdesc') + "', '" + token + "');"
    end

    def getDeleteButton(token)
      return "apijsDeleteAttachment(" + self.id.to_s + ", '" + getUrl('delete') + "', '" + token + "');"
    end

    def getShowButton(settingShowFilename, settingShowExifdate, description)
      if self.isImage?
        return "apijs.dialog.dialogPhoto('" + self.getShowUrl + "', '" + ((settingShowFilename) ? self.filename : 'false') + "', '" + ((settingShowExifdate) ? format_time(self.created_on) : 'false') + "', '" + description + "');"
      elsif self.isVideo?
        return "apijs.dialog.dialogVideo('" + self.getDownloadUrl + "', '" + ((settingShowFilename) ? self.filename : 'false') + "', '" + ((settingShowExifdate) ? format_time(self.created_on) : 'false') + "', '" + description + "');"
      elsif self.is_text?
        return "location.href = '" + getUrl('redmineshow', false) + "';"
      end
    end

    # image, photo, vidéo
    def isImage?
      return (self.filename =~ /\.(jpg|jpeg|png|svg)$/i) ? true : false
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
      return (self.filename =~ /\.(#{types.join('|')})$/i) ? true : false
    end

    def isVideo?
      types = []
      types.push('ogv')  if Setting.plugin_redmine_apijs['album_mimetype_ogv']  == '1'
      types.push('webm') if Setting.plugin_redmine_apijs['album_mimetype_webm'] == '1'
      types.push('mp4')  if Setting.plugin_redmine_apijs['album_mimetype_mp4']  == '1'
      types.push('m4v')  if Setting.plugin_redmine_apijs['album_mimetype_m4v']  == '1'
      return (self.filename =~ /\.(#{types.join('|')})$/i) ? true : false
    end

    # exclusion des fichiers
    def isExcluded?

      names = Setting.plugin_redmine_apijs['album_exclude_name']
      descs = Setting.plugin_redmine_apijs['album_exclude_desc']

      names = (names.blank?) ? [] : names.split(',')
      descs = (descs.blank?) ? [] : descs.split(',')

      unless names.empty?
        for token in names
          return true if (!self.filename.blank? && self.filename.index(token) == 0)
        end
      end

      unless descs.empty?
        for token in descs
          return true if (!self.description.blank? && self.description.index(token) == 0)
        end
      end

      return false
    end

    # lecture de la date exif et mise à jour de la date de création
    # uniquement lors de la création d'une pièce jointe photo ou vidéo
    # utilise la commande exiftool (libimage-exiftool-perl)
    def update_date

      if new_record? && (self.isPhoto? || self.isVideo?) && self.readable?

        command = 'exiftool -FastScan -IgnoreMinorErrors -DateTimeOriginal -S3 ' + self.diskfile + ' 2>&1'
        result  = `#{command}`.gsub(/^\s+|\s+$/, '')

        logger.info 'APIJS::AttachmentPatch#update_date: ' + command + ' (' + result + ')'

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
    # le bon dossier est définie en fonction du résultat de update_date
    def update_filedir!

      src = diskfile
      self.disk_directory = target_directory
      dest = diskfile

      return if src == dest

      if !FileUtils.mkdir_p(File.dirname(dest))
        logger.error 'Could not create directory ' + File.dirname(dest)
        return
      end

      if !FileUtils.mv(src, dest)
        logger.error 'Could not move attachment from ' + src + ' to ' + dest
        return
      end

      update_column :disk_directory, disk_directory if !new_record?
      logger.info 'APIJS::AttachmentPatch#update_filedir: moving file from ' + src + ' to ' + dest
    end

    # recherche du type mime
    # utilise la commande file (file)
    def getMimeType

        if self.readable? && self.content_type.blank?

          command = 'file --brief --mime-type ' + self.diskfile + ' 2>&1'
          result  = `#{command}`.gsub(/^\s+|\s+$/, '')
          logger.info 'APIJS::AttachmentPatch#getMimeType: ' + command + ' (' + result + ')'

          self.content_type = (result.length > 0) ? result : 'file/unknown'
          self.save!
        end

        return self.content_type
    end

  end
end

Attachment.send(:include, AttachmentPatch)