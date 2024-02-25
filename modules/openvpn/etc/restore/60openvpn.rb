require 'wiedii/system/log'
require 'wiedii/network/openvpn/vpn'
require 'wiedii/network/interface'

Wiedii::Network::OpenVPN::VPN.restore()


# Aren't upscripts used instead?

# re-run interfaces restore, after new TAP interfaces have been created
#Thread.new do
#  sleep 5
#  Wiedii::Network::Interface.restore()
#end

