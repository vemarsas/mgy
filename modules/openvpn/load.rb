class Wiedii
  module Network
    module OpenVPN
      ROOTDIR = File.dirname(__FILE__)
      $LOAD_PATH.unshift  ROOTDIR + '/lib'
      if Wiedii.web?
        Wiedii.find_n_load ROOTDIR + '/etc/menu'
        Wiedii.find_n_load ROOTDIR + '/controller'
      end
    end
  end
end


