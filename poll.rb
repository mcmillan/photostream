require 'gphoto4ruby'

`killall PTPCamera`

ports = GPhoto2::Camera.ports

raise 'No camera found' unless ports.any?

camera = GPhoto2::Camera.new(ports.first)

camera["capture"] = true
camera["capturetarget"] = "card"

while true do

  event = camera.wait

  next if event.type != 'file added'

  camera.save :to_folder => "#{Dir.pwd}/public/photos"

end