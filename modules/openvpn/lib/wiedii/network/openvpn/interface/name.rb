require 'wiedii/network/interface'

class Wiedii
  module Network
    module OpenVPN
      class Interface < ::Wiedii::Network::Interface
        module Name
          def self.generate(extra='')
            n = 0
            names =
                Interface.getAll.map  {|x| x.name}        |
                VPN.all_cached.map    {|x| x.data['dev']}
            name_ = nil
            while names.include? (name_ = "ovpn_#{extra}#{n}")
              n += 1
            end
            return name_
          end
        end
      end
    end
  end
end
