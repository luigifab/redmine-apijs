# encoding: utf-8
#
# Created V/27/12/2013
# Updated D/07/09/2014
# Version 27
#
# Copyright 2008-2014 | Fabrice Creuzot (luigifab) <code~luigifab~info>
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

module AttachmentPath

  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do
      unloadable
      if Rails::VERSION::MAJOR >= 3
        include Rails.application.routes.url_helpers
      else
        include ActionController::UrlWriter
      end
      before_save :update_date
    end
  end

  module InstanceMethods

    # construction des urls
    def getUrl(action, all=false)

      if (action == 'redmineshow')
        return url_for({ :only_path => true, :controller => 'attachments', :action => 'show', :id => self.id, :filename => self.filename })
      elsif all
        return url_for({ :only_path => true, :controller => 'apijs', :action => action, :id => self.id, :filename => self.filename })
      else
        return url_for({ :only_path => true, :controller => 'apijs', :action => action })
      end
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
      return "apijsEditAttachment(" + self.id.to_s + ", '" + getUrl('edit') + "', '" + token + "');"
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

    # image, photo ou vidéo
    def isImage?
      return (self.filename =~ /\.(jpg|jpeg|png|svg)$/i) ? true : false
    end
    def isPhoto?
      return (self.filename =~ /\.(jpg|jpeg)$/i) ? true : false
    end
    def isVideo?
      return (self.filename =~ /\.(ogv|webm|mp4|m4v)$/i) ? true : false
    end

    # exclusion des fichiers de l'album
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
        logger.info 'APIJS::AttachmentPath#update_date: ' + command + ' (' + result + ')'

        # 2014:06:14 16:43:53
        # utilise le fuseau horaire de l'utilisateur
        if result.length >= 19
          date = result[0..9].gsub(':', '-') + ' ' + result[11..18]
          zone = User.current.time_zone
          date = zone ? zone.parse(date) : date
          self.created_on = date
        end
      end
    end

    # recherche du type mime
    # utilise la commande file (file)
    def getMimeType

        if self.readable? && self.content_type.blank?

          command = 'file --brief --mime-type ' + self.diskfile + ' 2>&1'
          result  = `#{command}`.gsub(/^\s+|\s+$/, '')
          logger.info 'APIJS::AttachmentPath#getMimeType: ' + command + ' (' + result + ')'

          self.content_type = (result.length > 0) ? result : 'file/unknown'
          self.save!
        end

        return self.content_type
    end

  end
end

Attachment.send(:include, AttachmentPath)