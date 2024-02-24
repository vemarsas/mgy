require 'etc'

class Wiedii
  module System
    class User

      autoload :Passwd, 'wiedii/system/user/passwd'

      class << self
        def current
          new(Etc.getpwuid(::Process.uid))
        end
        def root
          new('root')
        end
      end

      attr_reader :passwd

      def initialize(x)
        @passwd = Passwd.new x
      end

      def method_missing(method, *args, &block)
        begin
          @passwd.entry.send(method, *args, &block)
        rescue NoMethodError
          @passwd.status.send(method, *args, &block)
        end
      end

    end
  end
end
