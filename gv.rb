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

# State
isfullscreen = false

index = files.index(filename)
p wd
p index
p filename

# Gtk
Gtk.init

screen = Gdk::Screen.default

pixbuf = Gdk::Pixbuf.new(files[index])
image = Gtk::Image.new()
#image.set(pixbuf)

window = Gtk::Window.new
window.title = "#{filename} - #{index + 1} / #{files.count}"
window.signal_connect("key_press_event") do |w, e|
	key = Gdk::Keyval.to_name(e.keyval)
	case key
		when "Right"
			if files.count > index + 1
				index = index + 1
				p files[index]
				pixbuf = Gdk::Pixbuf.new(files[index])
				if pixbuf.width > pixbuf.height
					if screen.width < pixbuf.width
						puts "resize require: width"
						scale = screen.width.to_f / pixbuf.width
						puts "#{(pixbuf.width * scale).to_i}x#{(pixbuf.height * scale).to_i}"
						pixbuf = pixbuf.scale((pixbuf.width * scale).to_i, (pixbuf.height * scale).to_i, Gdk::Pixbuf::INTERP_HYPER)
						image.set(pixbuf)

					end
				else
					if screen.height < pixbuf.height
						puts "resize require: height"
						scale = screen.height.to_f / pixbuf.height
						puts "#{(pixbuf.width * scale).to_i}x#{(pixbuf.height * scale).to_i}"
						pixbuf = pixbuf.scale((pixbuf.width * scale).to_i, (pixbuf.height * scale).to_i, Gdk::Pixbuf::INTERP_HYPER)
						image.set(pixbuf)
					end
				end


				window.title = "#{filename} - #{index + 1} / #{files.count}"
			end
		when "Left"
			if index - 1 >= 0
				index = index - 1
				p files[index]
				pixbuf = Gdk::Pixbuf.new(files[index])
				if pixbuf.width > pixbuf.height
					if screen.width < pixbuf.width
						puts "resize require: width"
						scale = screen.width.to_f / pixbuf.width
						puts "#{(pixbuf.width * scale).to_i}x#{(pixbuf.height * scale).to_i}"
						pixbuf = pixbuf.scale((pixbuf.width * scale).to_i, (pixbuf.height * scale).to_i, Gdk::Pixbuf::INTERP_HYPER)
						image.set(pixbuf)

					end
				else
					if screen.height < pixbuf.height
						puts "resize require: height"
						scale = screen.height.to_f / pixbuf.height
						puts "#{(pixbuf.width * scale).to_i}x#{(pixbuf.height * scale).to_i}"
						pixbuf = pixbuf.scale((pixbuf.width * scale).to_i, (pixbuf.height * scale).to_i, Gdk::Pixbuf::INTERP_HYPER)
						image.set(pixbuf)
					end
				end

				window.title = "#{filename} - #{index + 1} / #{files.count}"
			end
		when "Return"
			puts "enter"
			if !isfullscreen
				window.fullscreen()
				isfullscreen = true
			else
				window.unfullscreen()
				isfullscreen = false
			end

	end
end
window.signal_connect("destroy") do |w, e|
	puts "destroy event"
	Gtk.main_quit
end
#window.signal_connect("size_request") do |w, e|
#	puts "resize event"
#	if pixbuf.width > pixbuf.height
#		if screen.width < pixbuf.width
#			puts "resize require: width"
#		end
#	else
#		if screen.height < pixbuf.height
#			puts "resize require: height"
#			scale = screen.height.to_f /  pixbuf.height
#pixbuf.scale(pixbuf.width * scale, pixbuf.height * pixbuf.height)
#		end
#	end
#	size = window.size
#	puts "#{size[0]}x#{size[1]}"
#	resize(size, pixbuf)

#end

if pixbuf.width > pixbuf.height
	if screen.width < pixbuf.width
		puts "resize require: width"
		scale = screen.width.to_f / pixbuf.width
		puts "#{(pixbuf.width * scale).to_i}x#{(pixbuf.height * scale).to_i}"
		pixbuf = pixbuf.scale((pixbuf.width * scale).to_i, (pixbuf.height * scale).to_i, Gdk::Pixbuf::INTERP_HYPER)
		image.set(pixbuf)

	end
else
	if screen.height < pixbuf.height
		puts "resize require: height"
		scale = screen.height.to_f / pixbuf.height
		puts "#{(pixbuf.width * scale).to_i}x#{(pixbuf.height * scale).to_i}"
		pixbuf = pixbuf.scale((pixbuf.width * scale).to_i, (pixbuf.height * scale).to_i, Gdk::Pixbuf::INTERP_HYPER)
		image.set(pixbuf)
	end
end


window.add(image)
window.show_all
Gtk.main
