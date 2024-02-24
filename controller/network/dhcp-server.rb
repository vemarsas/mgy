require 'sinatra/base'

require 'wiedii/network/dnsmasq'

# this should be always safe: it's a no-op if a current
# configuration already exists
Wiedii::Network::Dnsmasq.init_conf

class Wiedii::Controller

  get "/network/dhcp-server.:format" do
    dnsmasq = Wiedii::Network::Dnsmasq.new
    dnsmasq.parse_dhcp_conf
    dnsmasq.parse_dhcp_leasefile
    format(
      :path     => 'network/dhcp-server',
      :format   => params[:format],
      :objects  => dnsmasq,
      :title    => 'DHCP Server'
    )
  end

  put "/network/dhcp-server.:format" do
    dnsmasq = Wiedii::Network::Dnsmasq.new
    msg = dnsmasq.write_dhcp_conf_from_HTTP_request(params)
    if msg[:err]
      status 409
    else
      Wiedii::PLATFORM::restart_dnsmasq(Wiedii::Network::Dnsmasq::CONFDIR + '/new')
    end

    # read updated conf
    dnsmasq = Wiedii::Network::Dnsmasq.new
    dnsmasq.parse_dhcp_conf
    dnsmasq.parse_dhcp_leasefile
    format(
      :path     => 'network/dhcp-server',
      :format   => params[:format],
      :objects  => dnsmasq,
      :msg      => msg,
      :title    => 'DHCP Server'
    )
  end

end
