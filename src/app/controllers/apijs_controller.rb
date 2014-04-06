# encoding: utf-8
#
# Created J/12/12/2013
# Updated V/10/01/2014
# Version 23
#
# Copyright 2013-2014 | Fabrice Creuzot (luigifab) <code~luigifab~info>
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

class ApijsController < AttachmentsController

  #before_filter :find_project, :except => :upload
  #before_filter :file_readable, :read_authorize, :only => [:show, :download]
  #before_filter :delete_authorize, :only => :destroy
  #before_filter :authorize_global, :only => :upload
  #accept_api_auth :show, :download, :upload
  before_filter :read_authorize, :file_readable, :only => [:thumb, :show, :download]
  before_filter :read_authorize, :only => [:edit, :delete]

  ROOT = ENV['RAILS_TMP'] ? (ENV['RAILS_TMP'] + '/apijs') : (ENV['RAILS_CACHE'] ? (ENV['RAILS_CACHE'] + '/apijs') : (Rails.root + '/tmp/apijs'))


  # #### Gestion de l'image miniature (photo ou vidéo) ################################ public ### #
  # = révision : 21
  # » Utilise un script python pour générer l'image miniature (taille 200x150, qualité 85)
  # » Utilise un script python pour générer l'image aperçu (taille 1200x900, qualité 85)
  # » Vérifie si l'utilisateur a accès au projet avant d'envoyer la miniature
  # » Utilise le système de cache de Ruby (stale?) et enregistre les commandes et leurs résultats dans les logs
  # » Utilise la commande python (avec python-imaging et ffmpegthumbnailer)
  def thumb

    # préparation de l'image
    source = @attachment.diskfile
    target = ROOT + '/thumb/' + @attachment.created_on.strftime('%Y-%m') + '/' + @attachment.id.to_s + ((@attachment.isVideo?) ? '.jpg' : File.extname(@attachment.filename))
    script = File.dirname(__FILE__).gsub('app/controllers', 'tools/image.py')

    # photo ou vidéo
    if @attachment.isVideo?
      # génération de l'image miniature
      if File.file?(source) && !File.file?(target)
        command = 'python ' + script + ' ' + source + ' ' + target + ' 200 150 video 2>&1'
        result  = `#{command}`.gsub(/^\s+|\s+$/, '')
        logger.info 'APIJS::ApijsController#thumb: ' + command + ' (' + result + ')'
      end
    else
      # génération de l'image miniature
      if File.file?(source) && !File.file?(target)
        command = 'python ' + script + ' ' + source + ' ' + target + ' 200 150 2>&1'
        result  = `#{command}`.gsub(/^\s+|\s+$/, '')
        logger.info 'APIJS::ApijsController#thumb: ' + command + ' (' + result + ')'
      end

      # génération de l'image aparçu
      if File.file?(source) && Setting.plugin_redmine_apijs['create_all'] == '1'
        target2 = ROOT + '/show/' + @attachment.created_on.strftime('%Y-%m') + '/' + @attachment.id.to_s + File.extname(@attachment.filename)
        if !File.file?(target2)
          command = 'python ' + script + ' ' + source + ' ' + target2 + ' 1200 900 2>&1'
          result  = `#{command}`.gsub(/^\s+|\s+$/, '')
          logger.info 'APIJS::ApijsController#thumb: ' + command + ' (' + result + ')'
        end
      end
    end

    # vérification si l'utilisateur a accès au projet
    if !User.current.allowed_to?({:controller => 'projects', :action => 'show'}, @project)
      if @project && @project.archived?
        render_403 :message => :notice_not_authorized_archived_project
      else
        deny_access
      end
    # envoie de l'image avec mise en cache
    elsif File.file?(target) && stale?(:etag => target)
      send_file(target, :filename => filename_for_content_disposition(@attachment.filename),
        :type => @attachment.getMimeType, :disposition => 'inline')
    end
  end


  # #### Gestion de l'image aperçu (photo) ############################################ public ### #
  # = révision : 22
  # » Utilise un script python pour générer l'image aperçu (taille 1200x900, qualité 85)
  # » Vérifie si l'utilisateur a accès au projet avant d'envoyer l'aperçu
  # » Utilise le système de cache de Ruby (stale?) et enregistre les commandes et leurs résultats dans les logs
  # » Utilise la commande python (avec python-imaging)
  def show

    # préparation de l'image
    source = @attachment.diskfile
    target = ROOT + '/show/' + @attachment.created_on.strftime('%Y-%m') + '/' + @attachment.id.to_s + File.extname(@attachment.filename)
    script = File.dirname(__FILE__).gsub('app/controllers', 'tools/image.py')

    # génération de l'image
    if File.file?(source) && !File.file?(target)
      command = 'python ' + script + ' ' + source + ' ' + target + ' 1200 900 2>&1'
      result  = `#{command}`.gsub(/^\s+|\s+$/, '')
      logger.info 'APIJS::ApijsController#show: ' + command + ' (' + result + ')'
    end

    # vérification si l'utilisateur a accès au projet
    if !User.current.allowed_to?({:controller => 'projects', :action => 'show'}, @project)
      if @project && @project.archived?
        render_403 :message => :notice_not_authorized_archived_project
      else
        deny_access
      end
    # envoie de l'image avec mise en cache
    elsif File.file?(target) && stale?(:etag => target)
      send_file(target, :filename => filename_for_content_disposition(@attachment.filename),
        :type => @attachment.getMimeType, :disposition => 'inline')
    end
  end


  # #### Gestion du téléchargement des fichiers ####################################### public ### #
  # = révision : 16
  # » Téléchargement d'une image avec mise en cache (inline/stale?) ou téléchargement d'un fichier (attachment)
  # » Vérifie si l'utilisateur a accès au projet avant d'envoyer le fichier
  def download

    # vérification si l'utilisateur a accès au projet
    if !User.current.allowed_to?({:controller => 'projects', :action => 'show'}, @project)
      if @project && @project.archived?
        render_403 :message => :notice_not_authorized_archived_project
      else
        deny_access
      end
    # téléchargement d'une image avec mise en cache ou téléchargement d'un fichier
    # => lorsque le paramètre filename n'est pas présent OU pour les images en dehors de l'album
    elsif !params[:filename] || params[:inline]
      @attachment.increment_download if @attachment.container.is_a?(Version) || @attachment.container.is_a?(Project)
      if @attachment.isImage?
        if stale?(:etag => @attachment.diskfile)
          send_file(@attachment.diskfile, :filename => filename_for_content_disposition(@attachment.filename),
            :type => @attachment.getMimeType, :disposition => 'inline')
        end
      else
        send_file(@attachment.diskfile, :filename => filename_for_content_disposition(@attachment.filename),
          :type => @attachment.getMimeType, :disposition => 'attachment')
      end
    # téléchargement d'un fichier
    else
      @attachment.increment_download if @attachment.container.is_a?(Version) || @attachment.container.is_a?(Project)
      send_file(@attachment.diskfile, :filename => filename_for_content_disposition(@attachment.filename),
        :type => @attachment.getMimeType, :disposition => 'attachment')
    end
  end


  # #### Modification d'une description ############################################### public ### #
  # = révision : 10
  # » Renvoie l'id du fichier suivi de la description en cas de succès
  # » Supprime certains caractères de la description avant son enregistrement
  # » Vérifie si l'utilisateur a accès au projet et à la modification
  def edit

    @attachment.description = params[:description].gsub(/["\\\x0]/, '')
    @attachment.description.strip!

    # vérification si l'utilisateur a accès au projet et à la modification
    if !User.current.allowed_to?({:controller => 'projects', :action => 'show'}, @project) || !User.current.allowed_to?(:edit_attachments, @project)
      if @project && @project.archived?
        render_403 :message => :notice_not_authorized_archived_project
      else
        deny_access
      end
    # modification
    elsif @attachment.save
      render(:text => 'attachmentId' + @attachment.id.to_s + ':' + @attachment.description)
    # en cas d'erreur
    else
      render_validation_errors(@attachment)
    end
  end


  # #### Suppression d'un fichier ##################################################### public ### #
  # = révision : 11
  # » Renvoie l'id du fichier suivi en cas de succès de suppression
  # » Supprime le fichier et les fichiers générés lorsque nécessaire
  # » Vérifie si l'utilisateur a accès au projet et à la suppresion
  def delete

    # vérification si l'utilisateur a accès au projet et à la suppression
    if !User.current.allowed_to?({:controller => 'projects', :action => 'show'}, @project) || !User.current.allowed_to?(:delete_attachments, @project)
      if @project && @project.archived?
        render_403 :message => :notice_not_authorized_archived_project
      else
        deny_access
      end
    # suppression
    elsif @attachment.delete

      @attachment.container.init_journal(User.current) if @attachment.container.respond_to?(:init_journal)
      @attachment.container.attachments.delete(@attachment)

      if @attachment.isPhoto?
        target = ROOT + '/thumb/' + @attachment.created_on.strftime('%Y-%m') + '/' + @attachment.id.to_s + File.extname(@attachment.filename)
        File.delete(target) if File.file?(target)
        target = ROOT + '/show/' + @attachment.created_on.strftime('%Y-%m') + '/' + @attachment.id.to_s + File.extname(@attachment.filename)
        File.delete(target) if File.file?(target)
      elsif @attachment.isVideo?
        target = ROOT + '/thumb/' + @attachment.created_on.strftime('%Y-%m') + '/' + @attachment.id.to_s + '.jpg'
        File.delete(target) if File.file?(target)
      end

      render(:text => 'attachmentId' + @attachment.id.to_s)
    # en cas d'erreur
    else
      render_validation_errors(@attachment)
    end
  end
end