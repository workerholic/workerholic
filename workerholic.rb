require 'yaml'
require 'pry-byebug'

require_relative 'job'
require_relative 'storage'
require_relative 'worker'

module Workerholic

  class Runner

    def self.run(options)

      job = Job.new(options[:klass], options[:args])
      job.push

      worker = Worker.new
      worker.poll
    end

  end

end
