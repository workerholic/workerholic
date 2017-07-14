require_relative '../lib/job'

class JobTestFast
  include Workerholic::Job

  def perform(str, num)
    puts "#{num} - #{str}"
  end
end

class JobTestSlow
  include Workerholic::Job

  def perform(str, num)
    sleep(1)
    puts "#{num} - #{str}"
  end
end
