require 'gphoto4ruby'
require 'rmagick'

`killall PTPCamera`

ports = GPhoto2::Camera.ports

raise 'No camera found' unless ports.any?

camera = GPhoto2::Camera.new(ports.first)

camera["capture"] = true
camera["capturetarget"] = "card"

while true do

  event = camera.wait

  next if event.type != 'file added'

  camera.save :to_folder => 'tmp'

  image   = Magick::Image.read("tmp/#{event.file}")[0]
  overlay = Magick::Image.read("cage.png")[0]

  image.resize_to_fit!(800)
  image.composite!(overlay, Magick::SouthEastGravity, Magick::OverCompositeOp)

  image.write("public/photos/#{event.file}")

  FileUtils.rm_rf("tmp/#{event.file}")

end