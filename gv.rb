require 'gtk2'


class Gv

  def initialize(argv)
    file_path = File::expand_path(argv)
    file_name = File::basename(file_path)
    file_dir = File::dirname(file_path)
    @isFullscreen = false


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

    show_image(@files[@index])


    @window.add(@image)
    @window.show_all
    Gtk.main

  end

  def show_image(file_name)
    p file_name
    @pixbuf = Gdk::Pixbuf.new(file_name)
    puts "#{@screen.width}x#{@screen.height}"
    if @pixbuf.width > @pixbuf.height
      if @screen.width < @pixbuf.width
        puts 'resize require: width'
        scale = @screen.width.to_f / @pixbuf.width
        puts "#{(@pixbuf.width * scale).to_i}x#{(@pixbuf.height * scale).to_i}"
        @pixbuf = @pixbuf.scale((@pixbuf.width * scale).to_i, (@pixbuf.height * scale).to_i, Gdk::Pixbuf::INTERP_HYPER)
        @image.set(@pixbuf)
      end
    else
      if @screen.height < @pixbuf.height
        puts 'resize require: height'
        scale = @screen.height.to_f / @pixbuf.height
        puts "#{(@pixbuf.width * scale).to_i}x#{(@pixbuf.height * scale).to_i}"
        @pixbuf = @pixbuf.scale((@pixbuf.width * scale).to_i, (@pixbuf.height * scale).to_i, Gdk::Pixbuf::INTERP_HYPER)
        @image.set(@pixbuf)
      end
    end


    @window.title = "#{file_name} - #{@index + 1} / #{@files.count}"
  end

  def key_event(e)
    key = Gdk::Keyval.to_name(e.keyval)
    case key
      when 'Right'
        if @files.count > @index + 1
          @index = @index + 1
          show_image(@files[@index])
        end
      when 'Left'
        if @index - 1 >= 0
          @index = @index - 1
          show_image(@files[@index])
        end
      when 'Return'
        puts 'enter'
        if !@isFullscreen
          @window.fullscreen
          @isFullscreen = true
        else
          @window.unfullscreen
          @isFullscreen = false
        end
    end

  end
end

p ARGV[0]
Gv.new(ARGV[0])
