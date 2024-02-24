require 'fileutils'

require 'wiedii/network/dnsmasq'

version_file = File.join Wiedii::CONFDIR, 'VERSION'

begin
  File.open version_file, 'w' do |f|
    f.write Wiedii::VERSION
  end
rescue
  FileUtils.mkdir_p Wiedii::CONFDIR
  retry
end



