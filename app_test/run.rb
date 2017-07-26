require_relative 'job_test'
require_relative '../lib/manager.rb'

# 100000.times do |n|
#   JobTestFast.new.perform_async('NONBLOCKING', n)
#   # sleep(0.0015)
# end

# 10000.times do |n|
#   JobTestSlow.new.perform_async('BLOCKING', n)
#   sleep(0.0015)
# end

# 100000.times do |n|
#   ThreadKiller.new.perform_async('Kill', n)
# end

# arg = Array.new(10000, 'string')
# 10000.times do |n|
#   LargeArg.new.perform_async(arg, n)
# end

# unsorted_array = (1..10000).to_a.shuffle
unsorted_array = (1..1000).to_a.shuffle
1000.times do |n|
  HeavyCalculation.new.perform_async(n, unsorted_array)
end

5_000.times do |n|
  JobTestFast.new.perform_async('NON BLOCKING', n)
  JobTestFast.new.perform_async('NON BLOCKING', n)
  # JobTestFast.new.perform_async('NON BLOCKING', n)
  # JobTestFast.new.perform_async('NON BLOCKING', n)
  # # JobTestSlow.new.perform_async('BLOCKING', n)
  JobTestSlow.new.perform_async('BLOCKING', n)
end

# 100000.times do |n|
#   ManyArgs.new.perform_async(n, [1, 2, 3], { key: 'value'}, :symb, 'string', 22, false)
# end

# 100000.times do |n|
#   GetPrimes.new.perform_async(n, 1000000)
# end
