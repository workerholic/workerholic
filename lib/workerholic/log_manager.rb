module Workerholic
  class LogManager
    attr_reader :logger

    def initialize
      @logger = Logger.new(STDOUT)
    end

    def log(severity, message)
      return if $TESTING

      logger.formatter = proc do |severity, datetime, progname, msg|
        "#{severity}: #{msg}\n"
      end

      logger.send(severity, message)
    end
  end
end
