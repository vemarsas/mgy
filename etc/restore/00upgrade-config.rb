require 'wiedii/extensions/array'
require 'wiedii/system/command'

# something like [2010, 8]
current_version = Wiedii::VERSION.split('.').map{|s| s.to_i}

begin
  saved_configuration_version_str = File.read File.join Wiedii::CONFDIR, 'VERSION'
  saved_configuration_version = saved_configuration_version_str.split('.').map{|s| s.to_i}
rescue Errno::ENOENT
  saved_configuration_version = [0, 0, 0]
end

if
    Dir.exists? Wiedii::CONFDIR              and # No config? Do not upgrade ;)
    saved_configuration_version <   [2010, 8] and
    current_version             >=  [2010, 8]

  print "\nNOTE: Upgrading configuration to version #{Wiedii::VERSION} ... "

  cmd = "#{Wiedii::ROOTDIR}/etc/scripts/migrate-config.sh"
  Wiedii::System::Command.run cmd

  load File.join Wiedii::ROOTDIR, '/etc/save/version.rb'
end




