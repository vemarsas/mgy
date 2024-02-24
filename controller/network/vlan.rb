require 'pp'
require 'sinatra/base'

require 'wiedii/network/interface'

class Wiedii::Controller

  get '/network/vlan.:format' do
    objects = Wiedii::Network::Interface.getAll.sort_by(
      &Wiedii::Network::Interface::PREFERRED_ORDER
    )
    format(
      :path     => '/network/vlan',
      :format   => params[:format],
      :objects  => objects,
      :title    => 'VLAN 802.1Q trunks'
    )
  end

  put '/network/vlan.:format' do
    Wiedii::Network::Interface.set_802_1q_trunks(params['vlan']['trunk'])

    updated_objects = Wiedii::Network::Interface.getAll.sort_by(
        &Wiedii::Network::Interface::PREFERRED_ORDER
    )

    format(
      :path     => '/network/vlan',
      :format   => params[:format],
      :title    => 'VLAN 802.1Q trunks',
      :objects  => updated_objects
    )
  end

end
