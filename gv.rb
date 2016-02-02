#!/usr/bin/ruby

require 'gtk2'

SLIDE_WAIT = 1 # 秒



class Gv

  def initialize(argv, isDir = false)

    if isDir
      file_dir = argv
      file_path = Dir::entries(file_dir)[0]
      file_name = File::basename(file_path)
    else
      file_path = File::expand_path(argv)
      file_name = File::basename(file_path)
      file_dir = File::dirname(file_path)

    end


    @isFullscreen = false
    @rotate = 0


    # FilePath
    Dir::chdir(file_dir)
    # wd = Dir::getwd
    @files = Dir::entries(file_dir).sort.select { |x|
      /^\.(bmp|png|gif|jpg|jpeg)/ =~ File::extname(x).downcase
    }
    @index = 0
    if !isDir
      @index = @files.index(file_name)
    end

    # Gtk
    Gtk.init

    @screen = Gdk::Screen.default
    #@pixbuf = Gdk::Pixbuf.new(@files[@index])
    @image = Gtk::Image.new()
    @window = Gtk::Window.new

    @window.signal_connect('key_press_event') do |w, e|
      key_event(e)
    end

    @window.signal_connect('destroy') do |w, e|
      puts 'destroy event'
      Gtk.main_quit
    end

    if isDir
      puts "Slideshow mode"
      toggle_fullscreen()

      GLib::Timeout.add(1000 * SLIDE_WAIT) do
        next_image(1, true)
      end
    end


    show_image(@files[@index], true)


    @window.add(@image)
    @window.show_all
    Gtk.main
  end

  def show_image(file_name, isFirst = nil)
    p file_name
    @pixbuf = Gdk::Pixbuf.new(file_name)
    @org_pix = @pixbuf.dup
    if @rotate != 0
      pixbuf_rotate(@rotate, false)
    end
    pixbuf_draw(isFirst)
    @window.title = "#{file_name} - #{@index + 1} / #{@files.count}"
  end

  def pixbuf_rotate(angle, isDraw = true)
    puts "angle: #{angle}"
    @pixbuf = @org_pix.dup
    for i in 1..angle do
      @pixbuf = @pixbuf.rotate(Gdk::Pixbuf::ROTATE_CLOCKWISE)
    end
    if isDraw
      pixbuf_draw()
    end
  end

  def pixbuf_draw(size = nil)
    puts "Screen: #{@screen.width}x#{@screen.height}"
    if size.nil? & !@isFullscreen
      if @pixbuf.width > @pixbuf.height
        if @window.size[0] < @pixbuf.width
          puts 'resize require: width'
          scale = @window.size[0].to_f / @pixbuf.width
          puts "#{(@pixbuf.width * scale).to_i}x#{(@pixbuf.height * scale).to_i}"
          p scale
          p @pixbuf.width * scale
          p @pixbuf.height * scale
          resized_width = (@pixbuf.width * scale).to_i
          resized_height = (@pixbuf.height * scale).to_i
          if resized_width < 1
            resized_width = 1
          end
          if resized_height < 1
            resized_height = 1
          end

          @pixbuf = @pixbuf.scale(resized_width, resized_height, Gdk::Pixbuf::INTERP_HYPER)
        end
      else
        if @window.size[1] < @pixbuf.height
          puts 'resize require: height'
          scale = @window.size[1].to_f / @pixbuf.height
          puts "#{(@pixbuf.width * scale).to_i}x#{(@pixbuf.height * scale).to_i}"
          resized_width = (@pixbuf.width * scale).to_i
          resized_height = (@pixbuf.height * scale).to_i
          if resized_width < 1
            resized_width = 1
          end
          if resized_height < 1
            resized_height = 1
          end

          @pixbuf = @pixbuf.scale(resized_width, resized_height, Gdk::Pixbuf::INTERP_HYPER)
        end
      end
      #@window.set_size_request(@pixbuf.width, @pixbuf.height)
    else
      if @pixbuf.width > @pixbuf.height
        if @screen.width < @pixbuf.width
          puts 'resize require: width mode screen'
          scale = @screen.width.to_f / @pixbuf.width
          puts "#{(@pixbuf.width * scale).to_i}x#{(@pixbuf.height * scale).to_i}"
          resized_width = (@pixbuf.width * scale).to_i
          resized_height = (@pixbuf.height * scale).to_i
          if resized_width < 1
            resized_width = 1
          end
          if resized_height < 1
            resized_height = 1
          end

          @pixbuf = @pixbuf.scale(resized_width, resized_height, Gdk::Pixbuf::INTERP_HYPER)
        end
      else
        if @screen.height < @pixbuf.height
          puts 'resize require: height mode screen'
          scale = @screen.height.to_f / @pixbuf.height
          puts "#{(@pixbuf.width * scale).to_i}x#{(@pixbuf.height * scale).to_i}"
          resized_width = (@pixbuf.width * scale).to_i
          resized_height = (@pixbuf.height * scale).to_i
          if resized_width < 1
            resized_width = 1
          end
          if resized_height < 1
            resized_height = 1
          end

          @pixbuf = @pixbuf.scale(resized_width, resized_height, Gdk::Pixbuf::INTERP_HYPER)
        end
      end

    end
    @image.set(@pixbuf)
  end

  def toggle_fullscreen()
    if !@isFullscreen
      @window.fullscreen
      @isFullscreen = true
    else
      @window.unfullscreen
      @isFullscreen = false
    end
  end

  def next_image(count = 1, isLoop = false)
    if @files.count > @index + count
      @index = @index + count
    else
      if isLoop
        @index = 0
      else
        @index = @files.count - 1
      end
    end
    show_image(@files[@index])
  end

  def key_event(e)
    key = Gdk::Keyval.to_name(e.keyval)
    p key
    case key
      when 'Right'
        if Gdk::Window::ModifierType::CONTROL_MASK == e.state & Gdk::Window::CONTROL_MASK
          next_image(10)
        else
          next_image()
        end
      when 'Left'
        if Gdk::Window::ModifierType::CONTROL_MASK == e.state & Gdk::Window::CONTROL_MASK
          if @index - 10 >= 0
            @index = @index - 10
          else
            @index = 0
          end
          show_image(@files[@index])
        else
          if @index - 1 >= 0
            @index = @index - 1
            show_image(@files[@index])
          end
        end
      when 'period'
        puts 'rotate: CClock'
        @rotate = @rotate + 1
        if @rotate > 3
          @rotate = 0
        end
        pixbuf_rotate(@rotate)
      when 'comma'
        puts 'rotate: Clock'
        @rotate = @rotate - 1
        if @rotate < 0
          @rotate = 3
        end
        pixbuf_rotate(@rotate)


      when 'Return'
        puts 'enter'
        toggle_fullscreen()
      when 'Escape'
        exit(0)
    end

  end
end


p ARGV[0]

# Slideshow mode
if ARGV[0] == '-s'
  gv = Gv.new(ARGV[1], true)
  p "hoge"
  loop do


    sleep 1
    #sleep SLIDE_WAIT
  end
else
  Gv.new(ARGV[0])
end


