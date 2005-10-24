require 'fileutils'
require 'tempfile'
require 'RMagick'
include Magick

module FileColumn # :nodoc:
  def self.append_features(base)
    super
    base.extend(ClassMethods)
  end

  def self.create_state(options,instance,attr)
    filename = instance[attr]
    if filename.nil? or filename.empty?
      NoUploadedFile.new(options,instance,attr)
    else
      PermanentUploadedFile.new(options,instance,attr)
    end
  end

  def self.init_options(defaults,attr)
    options = defaults.dup
    options[:store_dir] ||= File.join(options[:base_path], attr)
    options[:tmp_base_dir] ||= File.join(options[:store_dir], "tmp")
    FileUtils.mkpath([ options[:store_dir], options[:tmp_base_dir] ])

    options
  end

  class BaseUploadedFile

    def initialize(options,instance,attr)
      @options, @instance, @attr = options, instance, attr
    end


    def assign(file)
      if file.nil?
        delete
      else
        if file.original_filename.empty?
          self
        else
          upload(file)
        end
      end
    end

    def just_uploaded?
      @just_uploaded
    end

    def on_save(&blk)
      @on_save ||= []
      @on_save << Proc.new
    end
    
    # the following methods are overriden by sub-classes if needed

    def temp_path
      nil
    end

    def after_save
      @on_save.each { |blk| blk.call } if @on_save
      self
    end

    def after_destroy
    end

    attr_accessor :options

    private
    
    def store_dir
      @options[:store_dir]
    end

    def tmp_base_dir
      @options[:tmp_base_dir]
    end

    def clone_as(klass)
      klass.new(@options, @instance, @attr)
    end

  end
    

  class NoUploadedFile < BaseUploadedFile
    def delete
      # we do not have a file so deleting is easy
      self
    end

    def upload(file)
      # replace ourselves with a TempUploadedFile
      temp = clone_as TempUploadedFile
      temp.store_upload(file)
      temp
    end

    def absolute_path
      nil
    end

    def relative_path
      nil
    end

    def assign_temp(temp_path)
      return self if temp_path.nil? or temp_path.empty?
      temp = clone_as TempUploadedFile
      temp.parse_temp_path temp_path
      temp
    end
  end

  class TempUploadedFile < BaseUploadedFile

    def store_upload(file)
      @tmp_dir = FileColumn.generate_temp_name
      FileUtils.mkdir(File.join(tmp_base_dir, @tmp_dir))
      
      @filename = FileColumn::sanitize_filename(file.original_filename)
      @local_file_path = File.join(tmp_base_dir,@tmp_dir,@filename)
      
      # stored uploaded file into local_file_path
      # If it was a Tempfile object, the temporary file will be
      # cleaned up automatically, so we do not have to care for this
      if file.respond_to?(:local_path) and file.local_path and File.exists?(file.local_path)
        FileUtils.copy_file(file.local_path, @local_file_path)
      elsif file.respond_to?(:read)
        File.open(@local_file_path, "wb") { |f| f.write(file.read) }
      else
        raise ArgumentError.new("Do not know how to handle #{file.inspect}")
      end

      content_type = get_content_type((file.content_type.chomp if file.content_type))
      if content_type and @options[:mime_extensions][content_type]
        @filename = correct_extension(@filename,@options[:mime_extensions][content_type])
      end

      new_local_file_path = File.join(tmp_base_dir,@tmp_dir,@filename)
      FileUtils.mv(@local_file_path, new_local_file_path) unless new_local_file_path == @local_file_path
      @local_file_path = new_local_file_path
      
      @instance[@attr] = @filename
      @just_uploaded = true
    end

    # regular expressions to try for identifying extensions
    EXT_REGEXPS = [ 
      /^(.+)\.([^.]+\.[^.]+)$/, # matches "something.tar.gz"
      /^(.+)\.([^.]+)$/ # matches "something.jpg"
    ]

    # tries to identify and strip the extension of filename
    # if an regular expresion from EXT_REGEXPS matches and the
    # downcased extension is a known extension (in @options[:extensions])
    # we'll strip this extension
    def strip_extension(filename)
      EXT_REGEXPS.each do |regexp|
        if filename =~ regexp
          base,ext = $1, $2
          return base if @options[:extensions].include?(ext.downcase)
        end
      end
      filename
    end
    
    def correct_extension(filename, ext)
      strip_extension(filename) << ".#{ext}"
    end
    
    def parse_temp_path(temp_path)
      raise ArgumentError.new("invalid format of '#{temp_path}'") unless temp_path =~ %r{^((\d+\.)+\d+)/([^/].+)$}
      @tmp_dir, @filename = $1, FileColumn.sanitize_filename($3)
      @local_file_path = File.join(tmp_base_dir, @tmp_dir, @filename)

      @instance[@attr] = @filename
    end
    
    def upload(file)
      # store new file
      temp = clone_as TempUploadedFile
      temp.store_upload(file)
      
      # delete old copy
      delete_files

      # and return new TempUploadedFile object
      temp
    end

    def delete
      delete_files
      clone_as NoUploadedFile
    end

    def assign_temp(temp_path)
      return self if temp_path.nil? or temp_path.empty?
      # we can ignore this since we've already received a newly uploaded file

      # however, we delete the old temporary files
      temp = clone_as TempUploadedFile
      temp.parse_temp_path(temp_path)
      temp.delete_files

      self
    end

    def absolute_path
      File.expand_path(@local_file_path)
    end

    def relative_path
      File.join("tmp", @tmp_dir, @filename)
    end

    def temp_path
      File.join(@tmp_dir, @filename)
    end

    def after_save
      super

      # we have a newly uploaded image, move it to the correct location
      file = clone_as PermanentUploadedFile
      file.move_from(@local_file_path, @just_uploaded)

      # delete temporary files
      delete_files

      # replace with the new PermanentUploadedFile object
      file
    end

    def delete_files
      FileUtils.rm_rf(File.join(tmp_base_dir, @tmp_dir))
    end

    def get_content_type(fallback=nil)
      fallback
    end
  end

  
  class PermanentUploadedFile < BaseUploadedFile
    def initialize(*args)
      super *args
      @dir = File.join(store_dir,@instance.id.to_s)
      @filename = @instance[@attr]
      @filename = nil if @filename.empty?
    end

    def move_from(local_path, just_uploaded)
      # create a directory named after the primary key, first
      FileUtils.mkdir(@dir) unless File.exists?(@dir)
      
      # @@@ Hacked in by gary
      pic = Magick::Image.read(local_path).first
      
      maxwidth = 240
      maxheight = 320
      aspectratio = maxwidth.to_f / maxheight.to_f
      imgwidth = pic.columns
      imgheight = pic.rows
      imgratio = imgwidth.to_f / imgheight.to_f
      imgratio > aspectratio ? scaleratio = maxwidth.to_f / imgwidth : scaleratio = maxheight.to_f / imgheight
      pic.resize!(scaleratio)
      
      pic.write(local_path)
      
      # move the temporary file over
      FileUtils.mv local_path, @dir
      
      @filename = File.basename(local_path)
      @just_uploaded = just_uploaded

      # remove all old files in the directory
      # we do this _after_ moving the file to avoid a short period of
      # time where none of the two files is available
      FileUtils.rm(
                   Dir.entries(@dir).reject!{ |e| [".",".."].include?(e) or e == @filename }.
                     collect{ |e| File.join(@dir,e) }
                   )
      
    end

    def upload(file)
      temp = clone_as TempUploadedFile
      temp.store_upload(file)
      temp
    end

    def delete
      file = clone_as NoUploadedFile
      @instance[@attr] = nil
      file.on_save { delete_files }
      file
    end

    def absolute_path
      File.expand_path(File.join(@dir, @filename))
    end

    def relative_path
      File.join(@instance.id.to_s, @filename)
    end

    def assign_temp(temp_path)
      return nil if temp_path.nil? or temp_path.empty?

      temp = clone_as TempUploadedFile
      temp.parse_temp_path(temp_path)
      temp
    end

    def after_destroy
      delete_files
    end

    def delete_files
      FileUtils.rm_rf @dir
    end
    
  end
    
  # The FileColumn module allows you to easily handle file uploads. You can designate
  # one or more columns of your model's table as "file columns" like this:
  #
  #   class Entry < ActiveRecord::Base
  #
  #     file_column :image
  #   end
  #
  # Now, by default, an uploaded file "test.png" for an entry object with primary key 42 will
  # be stored in in "public/entry/image/42/test.png". The filename "test.png" will be stored
  # in the record's +image+ column.
  #
  # The methods of this module are automatically included into ActiveRecord::Base as class
  # methods, so that you can use them in your models.
  #
  # == Generated Methods
  #
  # After calling "<tt>file_column :image</tt>" as in the example above, a number of instance methods
  # will automatically be generated, all prefixed by "image":
  #
  # * <tt>Entry#image=(uploaded_file)</tt>: this will handle a newly uploaded file (see below). Note that
  #   you can simply call your upload field "entry[image]" in your view (or use the helper).
  # * <tt>Entry#image</tt>: This will return an absolute path (as a string) to the currently uploaded file
  #   or nil if no file has been uploaded
  # * <tt>Entry#image_relative_path</tt>: This will return a path relative to this file column's base 
  #   directory
  #   as a string or nil if no file has been uploaded. This would be "42/test.png" in the example.
  # * <tt>Entry#image_just_uploaded?</tt>: Returns true if a new file has been uploaded to this instance.
  #   You can use this in <tt>before_validation</tt> to resize images on newly uploaded files, for example.
  #
  # You can access the raw value of the "image" column (which will contain the filename) via the
  # <tt>ActiveRecord::Base#attributes</tt> or <tt>ActiveRecord::Base#[]</tt> methods like this:
  #
  #   entry['image']    # e.g."test.png"
  #
  # == Storage of uploaded file
  #
  # For a model class +Entry+ and a column +image+, all files will be stored under
  # "public/entry/image". A sub-directory named after the primary key of the object will
  # be created, so that files can be stored using their real filename. For example, a file
  # "test.png" stored in an Entry object with id 42 will be stored in
  #
  #   public/entry/image/42/test.png
  #
  # Files will be moved to this location in an +after_save+ callback. They will be stored in
  # a temporary location previously as explained in the next section.
  #
  # == Handling of form redisplay
  #
  # Suppose you have a form for creating a new object where the user can upload an image. The form may
  # have to be re-displayed because of validation errors. The uploaded file has to be stored somewhere so
  # that the user does not have to upload it again. FileColumn will store these in a temporary directory
  # (called "tmp" and located under the column's base directory by default) so that it can be moved to
  # the final location if the object is successfully created. If the form is never completed, though, you
  # can easily remove all the images in this "tmp" directory once per day or so.
  #
  # So in the example above, the image "test.png" would first be stored in 
  # "public/entry/image/tmp/<some_random_key>/test.png" and be moved to
  # "public/entry/image/<primary_key>/test.png".
  #
  # This temporary location of newly uploaded files has another advantage when updating objects. If the
  # update fails for some reasons (e.g. due to validations), the existing image will not be overwritten, so
  # it has a kind of "transactional behaviour".
  module ClassMethods

	
    MIME_EXTENSIONS = {
      "image/gif" => "gif",
      "image/jpeg" => "jpg",
      "image/pjpeg" => "jpg",
      "image/x-png" => "png",
      "image/jpg" => "jpg",
      "image/png" => "png",
      "application/x-shockwave-flash" => "swf",
      "application/pdf" => "pdf",
      "application/pgp-signature" => "sig",
      "application/futuresplash" => "spl",
      "application/msword" => "doc",
      "application/postscript" => "ps",
      "application/x-bittorrent" => "torrent",
      "application/x-dvi" => "dvi",
      "application/x-gzip" => "gz",
      "application/x-ns-proxy-autoconfig" => "pac",
      "application/x-shockwave-flash" => "swf",
      "application/x-tgz" => "tar.gz",
      "application/x-tar" => "tar",
      "application/zip" => "zip",
      "audio/mpeg" => "mp3",
      "audio/x-mpegurl" => "m3u",
      "audio/x-ms-wma" => "wma",
      "audio/x-ms-wax" => "wax",
      "audio/x-wav" => "wav",
      "image/x-xbitmap" => "xbm",             
      "image/x-xpixmap" => "xpm",             
      "image/x-xwindowdump" => "xwd",             
      "text/css" => "css",             
      "text/html" => "html",                          
      "text/javascript" => "js",
      "text/plain" => "txt",
      "text/xml" => "xml",
      "video/mpeg" => "mpeg",
      "video/quicktime" => "mov",
      "video/x-msvideo" => "avi",
      "video/x-ms-asf" => "asf",
      "video/x-ms-wmv" => "wmv"
    }

    EXTENSIONS = Set.new MIME_EXTENSIONS.values
    EXTENSIONS.merge %w(jpeg)

    DEFAULT_OPTIONS = {
      :root_path => File.join(RAILS_ROOT, "public"),
      :web_root => "",
      :mime_extensions => MIME_EXTENSIONS,
      :extensions => EXTENSIONS
    }.freeze
    
    # handle one or more attributes as "file-upload" columns, generating additional methods as explained
    # above. You should pass the names of the attributes as symbols, like this:
    #
    #   file_column :image, :another_image
    def file_column(*args)
      options = DEFAULT_OPTIONS.dup
      options.update(args.pop) if args.last.is_a?(Hash)
      
      options[:base_path] ||= File.join(options[:root_path], Inflector.underscore(self.name).to_s)
      options[:base_url] ||= options[:web_root]+"/"+Inflector.underscore(self.name).to_s+"/"
      args.each do |attr|
        my_options = FileColumn::init_options(options, attr.to_s)

        state_attr = "@#{attr}_state".to_sym
        state_method = "#{attr}_state".to_sym

        define_method state_method do
          result = instance_variable_get state_attr
          if result.nil?
            result = FileColumn::create_state(my_options, self, attr.to_s)
            instance_variable_set state_attr, result
          end
          result
        end
        
        private state_method

        define_method attr do
          send(state_method).absolute_path
        end
        
        define_method "#{attr}_relative_path" do
          send(state_method).relative_path
        end
        
        define_method "#{attr}=" do |file|
          instance_variable_set state_attr, send(state_method).assign(file)
        end

        define_method "#{attr}_temp" do
          send(state_method).temp_path
        end
        
        define_method "#{attr}_temp=" do |temp_path|
          instance_variable_set state_attr, send(state_method).assign_temp(temp_path)
        end

        after_save_method = "#{attr}_after_save".to_sym

        define_method after_save_method do
          instance_variable_set state_attr, send(state_method).after_save
        end

        after_save after_save_method
        
        after_destroy_method = "#{attr}_after_destroy".to_sym

        define_method after_destroy_method do
          send(state_method).after_destroy
        end
        after_destroy after_destroy_method
        
        define_method "#{attr}_just_uploaded?" do
          send(state_method).just_uploaded?
        end
        
        define_method "#{attr}_options" do
          send(state_method).options
        end
        
        private after_save_method, after_destroy_method
      end
    end
    
  end
  
  private
  
  def self.generate_temp_name
    now = Time.now
    "#{now.to_i}.#{now.usec}.#{Process.pid}"
  end
  
  def self.sanitize_filename(filename)
    filename = File.basename(filename.gsub("\\", "/")) # work-around for IE
    filename.gsub!(/[^a-zA-Z0-9\.\-\+_]/,"_")
    filename = "_#{filename}" if filename =~ /^\.+$/
    filename
  end
  
  def self.remove_file_with_dir(path)
    return unless File.file?(path)
    FileUtils.rm_f path
    dir = File.dirname(path)
    Dir.rmdir(dir) if File.exists?(dir)
  end

end
