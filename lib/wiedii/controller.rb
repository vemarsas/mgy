# encoding: utf-8

require 'rubygems'
require 'thin'
require 'sinatra/base'
require 'tilt/erb'

require 'rack'
require 'rack/contrib'

require 'wiedii/extensions/sinatra/base'

require 'wiedii/controller/auth'
require 'wiedii/controller/error'
require 'wiedii/controller/format'
require 'wiedii/controller/gui'
require 'wiedii/controller/locale'
require 'wiedii/controller/logger'
require 'wiedii/controller/thread'

class Wiedii
  class Controller < ::Sinatra::Base

    attr_accessor :msg
        # so you don't need to pass it between routes, views, helpers ...

    before do
      @msg = {}
    end

    # Several options are not enabled by default if you inherit from
    # Sinatra::Base .
    enable :method_override, :static, :show_exceptions

    if test?  # https://stackoverflow.com/a/10917840
      set :raise_errors, true
      set :dump_errors, false
      set :show_exceptions, false
    end

    set :root, Wiedii::ROOTDIR

    # Sinatra::Base#static! has been overwritten to allow multiple path
    set :public_folder,
        Dir.glob(Wiedii::ROOTDIR + '/public')            +
        Dir.glob(Wiedii::ROOTDIR + '/modules/*/public')

    set :views, Wiedii::ROOTDIR + '/views'

    not_found do
      @override_not_found ||= false
      status 404
      if @override_not_found
        pass
      else
        format(:path=>'404', :format=>'html')
      end
    end

    # modular controller
    Wiedii.find_n_load Wiedii::ROOTDIR + '/controller/'

  end

end
