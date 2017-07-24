require 'redis'

require_relative '../spec_helper'
require_relative '../../lib/job'
require_relative '../../lib/manager'
require_relative '../helpers/job_tests'

describe 'dequeuing and processesing of jobs' do
  it 'successfully dequeues and process a simple job'

  it 'successfully dequeues and process a complex job'

  context 'user interrupts process' do
    it 'finishes executing the current job before gracefully shutting down' do

    end
  end
end
