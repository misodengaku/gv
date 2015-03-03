require 'gtk2'


class Gv

  def initialize(argv)
    file_path = File::expand_path(argv)
    file_name = File::basename(file_path)
    file_dir = File::dirname(file_path)
    @isFullscreen = false
    @rotate = 0


    # FilePath
    Dir::chdir(file_dir)
    wd = Dir::getwd
    @files = Dir::entries(wd).sort.select { |x|
      /^\.(bmp|png|gif|jpg|jpeg)/ =~ File::extname(x).downcase
    }
    @index = @files.index(file_name)

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
          @pixbuf = @pixbuf.scale((@pixbuf.width * scale).to_i, (@pixbuf.height * scale).to_i, Gdk::Pixbuf::INTERP_HYPER)
        end
      else
        if @window.size[1] < @pixbuf.height
          puts 'resize require: height'
          scale = @window.size[1].to_f / @pixbuf.height
          puts "#{(@pixbuf.width * scale).to_i}x#{(@pixbuf.height * scale).to_i}"
          @pixbuf = @pixbuf.scale((@pixbuf.width * scale).to_i, (@pixbuf.height * scale).to_i, Gdk::Pixbuf::INTERP_HYPER)
        end
      end
      #@window.set_size_request(@pixbuf.width, @pixbuf.height)
    else
      if @pixbuf.width > @pixbuf.height
        if @screen.width < @pixbuf.width
          puts 'resize require: width mode screen'
          scale = @screen.width.to_f / @pixbuf.width
          puts "#{(@pixbuf.width * scale).to_i}x#{(@pixbuf.height * scale).to_i}"
          @pixbuf = @pixbuf.scale((@pixbuf.width * scale).to_i, (@pixbuf.height * scale).to_i, Gdk::Pixbuf::INTERP_HYPER)
        end
      else
        if @screen.height < @pixbuf.height
          puts 'resize require: height mode screen'
          scale = @screen.height.to_f / @pixbuf.height
          puts "#{(@pixbuf.width * scale).to_i}x#{(@pixbuf.height * scale).to_i}"
          @pixbuf = @pixbuf.scale((@pixbuf.width * scale).to_i, (@pixbuf.height * scale).to_i, Gdk::Pixbuf::INTERP_HYPER)
        end
      end

    end
    @image.set(@pixbuf)
  end

  def key_event(e)
    key = Gdk::Keyval.to_name(e.keyval)
    p key
    case key
      when 'Right'
        if Gdk::Window::ModifierType::CONTROL_MASK == e.state & Gdk::Window::CONTROL_MASK
          if @files.count > @index + 10
            @index = @index + 10
          else
            @index = @files.count - 1
          end
          show_image(@files[@index])
        else
          if @files.count > @index + 1
            @index = @index + 1
            show_image(@files[@index])
          end
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
        if !@isFullscreen
          @window.fullscreen
          @isFullscreen = true
        else
          @window.unfullscreen
          @isFullscreen = false
        end
      when 'Escape'
        exit(0)
    end

  end
end

p ARGV[0]
Gv.new(ARGV[0])
