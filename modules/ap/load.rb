require 'fileutils'

class Wiedii
  module Network
    module AP
      ROOTDIR = File.dirname(__FILE__)
      CONFDIR = File.join Wiedii::CONFDIR, '/network/ap'
      LOGDIR  = File.join Wiedii::LOGDIR, '/network/ap'
      VARRUN  = File.join Wiedii::VARRUN, '/network/ap'
      FileUtils::mkdir_p CONFDIR + '/new'
      FileUtils::mkdir_p LOGDIR
      FileUtils::mkdir_p VARRUN
      $LOAD_PATH.unshift  ROOTDIR + '/lib'
      if Wiedii.web?
        Wiedii.find_n_load ROOTDIR + '/etc/menu'
        Wiedii.find_n_load ROOTDIR + '/controller'
      end
    end
  end
end


