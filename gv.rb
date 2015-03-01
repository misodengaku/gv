require "gtk2"

# Argument
filepath = File::expand_path(ARGV[0])
filename = File::basename(filepath)
filedir = File::dirname(filepath)

# FilePath
Dir::chdir(filedir)
wd = Dir::getwd
files = Dir::entries(wd).sort.select { |x| 
	/^\.(bmp|png|gif|jpg|jpeg)/ =~ File::extname(x).downcase
}
index = files.index(filename)
p wd
p index
p filename

# Gtk
Gtk.init

pixbuf = Gdk::Pixbuf.new(files[index])
image = Gtk::Image.new()
image.set(pixbuf)

window = Gtk::Window.new
window.title = "#{filename} - #{index + 1} / #{files.count}"
window.signal_connect("key_press_event") do |w, e|
	key =  Gdk::Keyval.to_name(e.keyval)
	case key
	when "Right"
		if files.count > index + 1
			index = index + 1
			p files[index]
			pixbuf = Gdk::Pixbuf.new(files[index])
			image.set(pixbuf)
			window.title = "#{filename} - #{index + 1} / #{files.count}"
		end
	when "Left"
		if index - 1 >= 0
			index = index - 1
			p files[index]
			pixbuf = Gdk::Pixbuf.new(files[index])
			image.set(pixbuf)
			window.title = "#{filename} - #{index + 1} / #{files.count}"
		end
	end
end
window.signal_connect("destroy") do |w, e|
	puts "destroy event"
	Gtk.main_quit
end
window.add(image)

window.show_all

Gtk.main
