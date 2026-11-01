# encoding: utf-8
# Created J/12/12/2013
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

class ApijsController < AttachmentsController

  # before the actions and in this order:
  #      find_project: loads the attachment and its project (404 if not found or if the filename is wrong)
  #  authorize_global: checks the permission without project (upload, clearcache)
  #    read_authorize: the user can see the attachment (403 or login if not)
  #     file_readable: the file exists on the disk (404 if not)
  # before_action with Redmine 4+ (Rails 5.2+), because before_filter was removed in Rails 5.1
  if Redmine::VERSION::MAJOR >= 4
    before_action :find_project, except: [:upload, :clearcache]
    before_action :authorize_global, only: [:upload, :clearcache]
    before_action :read_authorize, :file_readable, only: [:preview, :download, :thumbnail]
    before_action :read_authorize, only: [:edit, :delete]
  else
    before_filter :find_project, except: [:upload, :clearcache]
    before_filter :authorize_global, only: [:upload, :clearcache]
    before_filter :read_authorize, :file_readable, only: [:preview, :download, :thumbnail]
    before_filter :read_authorize, only: [:edit, :delete]
  end

  # removed in Redmine 3+ (copy of 2.6.10)
  if Redmine::VERSION::MAJOR >= 3
    def find_project
      @attachment = Attachment.find(params[:id])
      raise ActiveRecord::RecordNotFound if params[:filename] && params[:filename] != @attachment.filename
      @project = @attachment.project
    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end

  # Preview image (photo or video)
  # Sends the image with cache (inline/stale)
  #  getUrl('thumb')  → /apijs/preview/thumb/42/photo.jpg
  #  getUrl('srcset') → /apijs/preview/srcset/42/photo.jpg
  #  getUrl('show')   → /apijs/preview/show/42/photo.jpg
  # for svg files only show
  def preview

    type = params[:type]
    path = @attachment.diskfile

    # the user can see the project (403 or login if not)
    unless User.current.allowed_to?({controller: 'projects', action: 'show'}, @project)
      deny_access
      return
    end

    # only for photos and videos (404 if not)
    unless @attachment.isPhoto? || @attachment.isVideo?
      render_404
      return
    end

    # the file exists on the disk (404 if not)
    unless File.file?(path)
      render_404
      return
    end

    # the images of the file (404 if the requested image is not one of them)
    #    svg: only show, because the svg file is not resized
    #  video: thumb and srcset, because the video is played with download
    #  photo: thumb, srcset and show
    if @attachment.getPreviewExt == '.svg'
      types = ['show']
    elsif @attachment.isVideo?
      types = ['thumb', 'srcset']
    else
      types = ['thumb', 'srcset', 'show']
    end
    unless types.include?(type)
      render_404
      return
    end

    final = @attachment.getPreviewPath(type)
    if !File.file?(final)
      mode = Setting.plugin_redmine_apijs['create_all']
      # all the images at the same time (multi thread)
      if mode == '2'
        threads = types.map { |type| Thread.new { @attachment.createPreview(type) } }
        threads.each { |thread| thread.join }
      # all the images one after the other (single thread)
      elsif mode == '1'
        types.each { |type| @attachment.createPreview(type) }
      # only the requested image
      else
        @attachment.createPreview(type)
      end
    end

    # 404 File Not Found
    if !File.file?(final)
      render_404
    # 200 OK, with the image
    # 304 Not Modified, sent by stale?
    elsif stale?(etag: final)
      send_file(final, filename: filename_for_content_disposition(@attachment.filename), type: @attachment.getMimeType(final), disposition: 'inline')
    end
  end

  # File download
  # Sends a part of the file with 206 Partial Content (https://stackoverflow.com/a/7604330 + https://stackoverflow.com/a/16593030)
  # Sends the file with cache (stale), inline for pdf like Redmine, attachment for other files
  #  getUrl('download') → /apijs/download/42/photo.jpg
  def download

    path = @attachment.diskfile
    type = @attachment.getMimeType

    # the user can see the project (403 or login if not)
    unless User.current.allowed_to?({controller: 'projects', action: 'show'}, @project)
      deny_access
      return
    end

    # the file exists on the disk (404 if not)
    unless File.file?(path)
      render_404
      return
    end

    file_begin = 0
    file_size  = @attachment.filesize
    file_end   = file_size - 1

    # Range header, to send only a part of the file (videos, pdf, resumed downloads)
    #  bytes=100-199 → from 100 to 199
    #  bytes=100-    → from 100 to the end of the file
    #  bytes=-500    → the last 500 bytes
    #  bytes=0-99,200-299 → only the first range (0-99)
    #  no header or invalid header (bytes=-, bytes=abc) → all the file (200 OK)
    match = request.headers['Range'].to_s.match(/bytes=(\d*)-(\d*)/)
    match = nil if match && match[1].empty? && match[2].empty?

    if match
      # with a start (bytes=100-199 or bytes=100-)
      unless match[1].empty?
        file_begin = match[1].to_i
        file_end = match[2].to_i unless match[2].empty?
      # without a start, the end of the file (bytes=-500)
      else
        file_begin = file_size - match[2].to_i
        file_begin = 0 if file_begin < 0
      end
      # not after the end of the file
      file_end = file_size - 1 if file_end >= file_size
      # 416 Range Not Satisfiable, the start is after the end
      if file_begin > file_end
        response.header['Content-Range'] = 'bytes */' + file_size.to_s
        head 416
        return
      end
    end

    response.header['Accept-Ranges']  = 'bytes'
    response.header['Content-Length'] = (file_end - file_begin + 1).to_s
    response.header['Last-Modified']  = @attachment.created_on.httpdate
    disposition = @attachment.isPdf? ? 'inline' : 'attachment'

    # 206 Partial Content, with a part of the file
    if match
      left = file_end - file_begin + 1
      response.status = 206
      response.header['Content-Type']            = type
      response.header['Content-Range']           = 'bytes ' + file_begin.to_s + '-' + file_end.to_s + '/' + file_size.to_s
      response.header['Content-Disposition']     = disposition
      response.header['content-security-policy'] = "default-src 'none'; media-src 'self'; style-src 'unsafe-inline'; sandbox"
      self.response_body = Enumerator.new { |out|
        File.open(path, 'rb') { |f|
          f.seek(file_begin)
          while left > 0 && (chunk = f.read([left, 65536].min))
            left -= chunk.bytesize
            out << chunk
          end
        }
      }
    # 200 OK, with the file
    # 304 Not Modified, sent by stale?
    elsif stale?(etag: path)
      @attachment.increment_download if @attachment.container.is_a?(Version) || @attachment.container.is_a?(Project)
      send_file(path, filename: filename_for_content_disposition(@attachment.filename), type: type, disposition: disposition)
    end
  end

  # Edit the description or the name of the file
  # Returns the file id followed by the new value when it is saved
  # Removes some characters from the new value before saving
  #  getUrl('name') → /apijs/edit/name, POST ?id=42 with name=...
  #  getUrl('desc') → /apijs/edit/desc, POST ?id=42 with desc=...
  def edit

    type = params[:type]
    permission = (type == 'name') ? :rename_attachments : :edit_attachments

    # the user can see the project and can edit (desc) or rename (name) the attachments (403 or login if not)
    unless User.current.allowed_to?({controller: 'projects', action: 'show'}, @project) && User.current.allowed_to?(permission, @project)
      deny_access
      return
    end

    if type == 'name'
      name = File.basename(params[:name].to_s.gsub(/["\\\x0]/, '')).strip
      if File.extname(name).downcase != File.extname(@attachment.filename).downcase
        text = l(:apijs_check_extension)
        render_mytext(text)
        return
      end
      @attachment.filename = name
    else
      desc = params[:desc].to_s.gsub(/["\\\x0]/, '').strip
      @attachment.description = desc
    end

    if @attachment.save
      value = (type == 'name') ? @attachment.filename : @attachment.description
      render_mytext('attachmentId' + @attachment.id.to_s + ':' + value)
    else
      render_mytext(@attachment.errors.full_messages.join(', '))
    end
  end

  # Delete a file
  # Returns the file id when the file is deleted
  #  getUrl('delete') → /apijs/delete, POST ?id=42
  def delete

    # the user can see the project and can delete the attachments (403 or login if not)
    unless User.current.allowed_to?({controller: 'projects', action: 'show'}, @project) && User.current.allowed_to?(:delete_attachments, @project)
      deny_access
      return
    end

    @attachment.container.init_journal(User.current) if @attachment.container.respond_to?(:init_journal)
    @attachment.container.attachments.delete(@attachment)

    render_mytext('attachmentId' + @attachment.id.to_s)
  end

  # Clear the cache
  def clearcache

    # only for administrators (403 or login if not)
    unless User.current.admin?
      deny_access
    else
      if APIJS_ROOT.length > 5 && File.directory?(APIJS_ROOT)
        FileUtils.rm_rf(APIJS_ROOT)
        flash[:notice] = l(:apijs_clearcache_done)
      end
      redirect_to controller: 'settings', action: 'plugin', id: 'redmine_apijs'
    end
  end

  private

  def send_file(path, options={})
    super
    headers['content-security-policy'] = "default-src 'none'; media-src 'self'; style-src 'unsafe-inline'; sandbox"
  end

  def render_mytext(text)
    if Rails::VERSION::MAJOR >= 5
      render(plain: text)
    else
      render(text: text)
    end
  end

end