class Wiedii
  class Controller < ::Sinatra::Base

    case environment
    when :development
      Wiedii::LOGGER.level = Logger::DEBUG
    when :production
      Wiedii::LOGGER.level = Logger::INFO
    end

  end
end
