# encoding: utf-8
# Created J/12/12/2013
# Updated D/11/08/2019
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

class ApijsController < AttachmentsController

  if Redmine::VERSION::MAJOR >= 4
    before_action :find_project, :except => [:upload]
    before_action :authorize_global, :only => [:upload]
    before_action :read_authorize, :file_readable, :only => [:thumb, :show, :download, :thumbnail]
    before_action :read_authorize, :only => [:editdesc, :delete]
  else
    before_filter :find_project, :except => [:upload]
    before_filter :authorize_global, :only => [:upload]
    before_filter :read_authorize, :file_readable, :only => [:thumb, :show, :download, :thumbnail]
    before_filter :read_authorize, :only => [:editdesc, :delete]
  end

  # n'existe plus avec Redmine 3+ (copie de 2.6.10)
  if Redmine::VERSION::MAJOR >= 3
    def find_project
      @attachment = Attachment.find(params[:id])
      raise ActiveRecord::RecordNotFound if params[:filename] && params[:filename] != @attachment.filename
      @project = @attachment.project
    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end


  # #### Gestion de l'image miniature (photo ou vidéo) ################################ public ### #
  # » Vérifie si l'utilisateur a accès au projet avant l'envoi de la miniature au format JPG uniquement
  # » Utilise un script python pour générer l'image miniature (taille 200x150, qualité 85)
  # » Utilise un script python pour générer l'image aperçu (taille 1200x900, qualité 85)
  # » Utilise la commande python (avec python-imaging, ghostscript, ffmpegthumbnailer)
  # » Enregistre les commandes et leurs résultats dans les logs
  # » Téléchargement d'une image avec mise en cache (inline/stale?)
  def thumb

    # préparation de l'image
    source = @attachment.diskfile
    target = APIJS_ROOT + '/thumb/' + @attachment.created_on.strftime('%Y-%m').to_s + '/' + @attachment.id.to_s + '.jpg'
    script = File.dirname(__FILE__).gsub('app/controllers', 'tools/image.py')

    # génération des images
    if @attachment.isVideo?
      # génération de l'image miniature
      if File.file?(source) && !File.file?(target)
        command = 'python ' + script.to_s + ' ' + source.to_s + ' ' + target.to_s + ' 200 150 2>&1'
        result  = `#{command}`.gsub(/^\s+|\s+$/, '')
        logger.info 'APIJS::ApijsController#thumb: ' + command + ' (' + result + ')'
      end
    else
      # génération de l'image miniature
      if File.file?(source) && !File.file?(target)
        command = 'python ' + script.to_s + ' ' + source.to_s + ' ' + target.to_s + ' 200 150 2>&1'
        result  = `#{command}`.gsub(/^\s+|\s+$/, '')
        logger.info 'APIJS::ApijsController#thumb: ' + command + ' (' + result + ')'
      end
      # génération de l'image aparçu
      if File.file?(source) && Setting.plugin_redmine_apijs['create_all'] == '1'
        target2 = APIJS_ROOT + '/show/' + @attachment.created_on.strftime('%Y-%m').to_s + '/' + @attachment.id.to_s + File.extname(@attachment.filename).to_s
        if !File.file?(target2)
          command = 'python ' + script.to_s + ' ' + source.to_s + ' ' + target2.to_s + ' 1200 900 2>&1'
          result  = `#{command}`.gsub(/^\s+|\s+$/, '')
          logger.info 'APIJS::ApijsController#thumb: ' + command + ' (' + result + ')'
        end
      end
    end

    # vérification d'accès
    if !User.current.allowed_to?({:controller => 'projects', :action => 'show'}, @project)
      deny_access
    # envoie de l'image avec mise en cache
    elsif File.file?(target) && stale?(:etag => target)
      send_file(target, :filename => filename_for_content_disposition(@attachment.filename.gsub(/\.\w+$/i, '.jpg')), :type => 'image/jpeg', :disposition => 'inline')
    end
  end


  # #### Gestion de l'image aperçu (photo) ############################################ public ### #
  # » Vérifie si l'utilisateur a accès au projet avant l'envoi de l'aperçu au format JPG ou PNG
  # » Utilise un script python pour générer l'image aperçu sauf pour les images PNG (taille 1200x900, qualité 85)
  # » Utilise la commande python (avec python-imaging, ghostscript, ffmpegthumbnailer)
  # » Enregistre les commandes et leurs résultats dans les logs
  # » Téléchargement d'une image avec mise en cache (inline/stale?)
  def show

    # préparation de l'image
    source = @attachment.diskfile
    target = APIJS_ROOT + '/show/' + @attachment.created_on.strftime('%Y-%m').to_s + '/' + @attachment.id.to_s + '.jpg'
    script = File.dirname(__FILE__).gsub('app/controllers', 'tools/image.py')

    # génération de l'image
    if File.file?(source) && !File.file?(target) && @attachment.filename !~ /\.png$/i
      command = 'python ' + script.to_s + ' ' + source.to_s + ' ' + target.to_s + ' 1200 900 2>&1'
      result  = `#{command}`.gsub(/^\s+|\s+$/, '')
      logger.info 'APIJS::ApijsController#show: ' + command + ' (' + result + ')'
    end

    # vérification d'accès
    if !User.current.allowed_to?({:controller => 'projects', :action => 'show'}, @project)
      deny_access
    # envoie de l'image avec mise en cache (!=PNG)
    elsif File.file?(target) && stale?(:etag => target)
      send_file(target, :filename => filename_for_content_disposition(@attachment.filename.gsub(/\.\w+$/i, '.jpg')), :type => 'image/jpeg', :disposition => 'inline')
    # envoie de l'image avec mise en cache (=PNG)
    elsif File.file?(source) && stale?(:etag => source) && @attachment.filename =~ /\.png$/i
      send_file(source, :filename => filename_for_content_disposition(@attachment.filename), :type => 'image/png', :disposition => 'inline')
    end
  end


  # #### Gestion du téléchargement des fichiers ####################################### public ### #
  # » Vérifie si l'utilisateur a accès au projet avant tout
  # » Téléchargement d'une vidéo en 206 Partial Content (inline)
  # » Téléchargement d'une image avec mise en cache (inline/stale?) ou téléchargement d'un fichier (attachment)
  def download

    # vérification d'accès
    if !User.current.allowed_to?({:controller => 'projects', :action => 'show'}, @project)
      deny_access
    # ou télachargement d'une vidéo en 206 Partial Content (https://stackoverflow.com/a/7604330 + https://stackoverflow.com/a/16593030)
    # ou téléchargement d'une image avec mise en cache
    # ou téléchargement d'un fichier
    elsif !params[:filename] || params[:inline] || params[:stream]
      @attachment.increment_download if @attachment.container.is_a?(Version) || @attachment.container.is_a?(Project)
      # vidéo
      if @attachment.isVideo?
        file_begin = 0
        file_size = @attachment.filesize
        file_end = file_size - 1

        if request.headers['Range']
          match = request.headers['Range'].match(/bytes=(\d+)-(\d*)/)
          if match
            file_begin = match[1].to_i
            file_end = match[2].to_i if match[2] && !match[2].empty?
          end
        end

        response.header['Accept-Ranges']  = 'bytes'
        response.header['Content-Range']  = 'bytes ' + file_begin.to_s + '-' + file_end.to_s + '/' + file_size.to_s
        response.header['Content-Length'] = (file_end - file_begin + 1).to_s
        response.header['Last-Modified']  = @attachment.created_on.strftime('%a, %d %b %Y %H:%M:%S %z').to_s

        if !request.headers['Range']
          send_file(@attachment.diskfile,
            :filename => filename_for_content_disposition(@attachment.filename),
            :type => @attachment.getMimeType, :disposition => 'inline')
        else
          send_data(File.binread(@attachment.diskfile, file_end - file_begin + 1, file_begin),
            :filename => filename_for_content_disposition(@attachment.filename),
            :type => @attachment.getMimeType, :disposition => 'inline', :status => '206 Partial Content')
        end

        response.close
      # image/photo
      elsif @attachment.isImage?
        if stale?(:etag => @attachment.diskfile)
          send_file(@attachment.diskfile, :filename => filename_for_content_disposition(@attachment.filename),
            :type => @attachment.getMimeType, :disposition => 'inline')
        end
      # fichier
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
  # » Vérifie si l'utilisateur a accès au projet et à la modification
  # » Renvoie l'id du fichier suivi de la description en cas de modification réussie
  # » Supprime certains caractères de la description avant son enregistrement
  def editdesc

    @attachment.description = params[:description].gsub(/["\\\x0]/, '')
    @attachment.description.strip!

    # vérification d'accès
    if !User.current.allowed_to?({:controller => 'projects', :action => 'show'}, @project) || !User.current.allowed_to?(:edit_attachments, @project)
      deny_access
    # modification
    elsif @attachment.save
      if Rails::VERSION::MAJOR >= 5
        render(:plain => 'attachmentId' + @attachment.id.to_s + ':' + @attachment.description)
      else
        render(:text => 'attachmentId' + @attachment.id.to_s + ':' + @attachment.description)
      end
    # en cas d'erreur
    else
      render_validation_errors(@attachment)
    end
  end


  # #### Suppression d'un fichier ##################################################### public ### #
  # » Vérifie si l'utilisateur a accès au projet et à la suppresion
  # » Renvoie l'id du fichier suivi en cas de suppression réussie
  # » Supprime définitivement le fichier et les fichiers générés (miniature et aperçu)
  def delete

    # vérification d'accès
    if !User.current.allowed_to?({:controller => 'projects', :action => 'show'}, @project) || !User.current.allowed_to?(:delete_attachments, @project)
      deny_access
    # suppression
    elsif @attachment.delete
      @attachment.container.init_journal(User.current) if @attachment.container.respond_to?(:init_journal)
      @attachment.container.attachments.delete(@attachment)

      if @attachment.isPhoto?
        target = APIJS_ROOT + '/thumb/' + @attachment.created_on.strftime('%Y-%m').to_s + '/' + @attachment.id.to_s + File.extname(@attachment.filename).to_s
        File.delete(target) if File.file?(target)
        target = APIJS_ROOT + '/show/' + @attachment.created_on.strftime('%Y-%m').to_s + '/' + @attachment.id.to_s + File.extname(@attachment.filename).to_s
        File.delete(target) if File.file?(target)
      elsif @attachment.isVideo?
        target = APIJS_ROOT + '/thumb/' + @attachment.created_on.strftime('%Y-%m').to_s + '/' + @attachment.id.to_s + '.jpg'
        File.delete(target) if File.file?(target)
      end

      if Rails::VERSION::MAJOR >= 5
        render(:plain => 'attachmentId' + @attachment.id.to_s)
      else
        render(:text => 'attachmentId' + @attachment.id.to_s)
      end
    # en cas d'erreur
    else
      render_validation_errors(@attachment)
    end
  end
end