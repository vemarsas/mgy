class Wiedii
  module Network
    module Routing

      CONFDIR = Wiedii.const_defined?(:CONFDIR) ?
        File.join(Wiedii::CONFDIR, 'network/routing') :
        nil

      class RulesExist < ::RuntimeError; end

    end
  end
end


