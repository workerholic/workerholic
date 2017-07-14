require 'redis'

require_relative 'spec_helper'

class SimpleJobTest
  include Workerholic::Job

  def perform(s)
    s
  end
end

class ComplexJobTest
  include Workerholic::Job

  def perform(arg1, arg2, arg3)
    [arg1, arg2, arg3]
  end
end

describe 'it successfully dequeues a job and processes it' do
  it 'successfully dequeues and process a simple job' do

  end

  it 'successfully dequeues and process a complex job' do
    expect().to eq(ComplexJobTest.new.perform())
  end
end
