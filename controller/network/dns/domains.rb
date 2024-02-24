require 'sinatra/base'

require 'wiedii/network/dnsmasq'

class Wiedii
  class Controller

    get "/network/dns/domains.:format" do
      dnsmasq = Network::Dnsmasq.new
      dnsmasq.parse_dns_conf(
        "#{Network::Dnsmasq::CONFDIR_CURRENT}/domains.conf"
      )
      dnsmasq.parse_dns_cmdline
      format(
        :path     => 'network/dns/domains',
        :format   => params[:format],
        :objects  => dnsmasq,
        :title    => 'DNS: domains'
      )
    end

    put "/network/dns/domains.:format" do
      dnsmasq = Wiedii::Network::Dnsmasq.new
      msg = dnsmasq.write_domains_conf_from_HTTP_request(params)
      if msg[:err]
        status 409
      else
        Wiedii::PLATFORM::restart_dnsmasq(Wiedii::Network::Dnsmasq::CONFDIR + '/new')
      end

      # read updated conf
      dnsmasq = Wiedii::Network::Dnsmasq.new
      dnsmasq.parse_dns_conf(
        "#{Network::Dnsmasq::CONFDIR_CURRENT}/domains.conf"
      )
      dnsmasq.parse_dns_cmdline
      format(
        :path     => 'network/dns/domains',
        :format   => params[:format],
        :objects  => dnsmasq,
        :msg      => msg,
        :title    => 'DNS: domains'
      )
    end

  end
end
