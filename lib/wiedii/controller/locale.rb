require 'sinatra/r18n'

class Wiedii
  class Controller < ::Sinatra::Base

    # Extensions must be explicitly registered in modular style apps.
    register ::Sinatra::R18n

    ::R18n.default_places =
        [File.join(ROOTDIR, 'i18n')] +
        Dir.glob("#{ROOTDIR}/modules/*/i18n")

    #set(
    #  :translations,
    #  [File.join(ROOTDIR, 'i18n')] + Dir.glob("#{ROOTDIR}/modules/*/i18n")
    #)

  end
end
