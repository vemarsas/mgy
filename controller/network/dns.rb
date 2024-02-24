require 'sinatra/base'

require 'wiedii/network/dnsmasq'

class Wiedii::Controller

  get "/network/dns.:format" do
    dnsmasq = Wiedii::Network::Dnsmasq.new
    dnsmasq.parse_dns_conf
    dnsmasq.parse_dns_cmdline
    format(
      :path     => 'network/dns',
      :format   => params[:format],
      :objects  => dnsmasq,
      :title    => 'DNS'
    )
  end

  put "/network/dns.:format" do
    dnsmasq = Wiedii::Network::Dnsmasq.new
    msg = dnsmasq.write_dns_conf_from_HTTP_request(params)
    if msg[:err]
      status 409
    else
      Wiedii::PLATFORM::restart_dnsmasq(Wiedii::Network::Dnsmasq::CONFDIR + '/new')
    end

    # read updated conf
    dnsmasq = Wiedii::Network::Dnsmasq.new
    dnsmasq.parse_dns_conf
    dnsmasq.parse_dns_cmdline
    format(
      :path     => 'network/dns',
      :format   => params[:format],
      :objects  => dnsmasq,
      :msg      => msg,
      :title    => 'DNS'
    )
  end

end
