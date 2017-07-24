```ruby
class JobTestFast
  include Workerholic::Job

  def perform(str, num)
    puts "#{num} - #{str}"
  end
end

100000.times do |n|
  JobTestFast.new.perform_async('NON BLOCKING', n)
end
```

Potential problems? Creating an extra instance in enqueuing and dequeuing side.

All tests are run using specs of a Macbook Pro Early 2015 - 2.7 GHz Intel Dual Core i5.

7/21: aeae66c100e777bfff103d21a80fae3f915c3e2e

Notes:
* The workers processes jobs much more quickly than they are enqueued. Therefore, there are no problems if we enqueue and process the jobs asynchronously. However, that does not get us an accurate benchmark on just the processing side.
* It seems that if we try to enqueue too many jobs in a short period of time, redis will error out. In ~19 seconds, we are able to enqueue 16350~ job before it crashes.
  * To remedy this, we tried to sleep between enqueues for 0.001 second. No change in result, instead it took ~42 seconds to error out.
  * Tried sleeping between enqueues for 0.003. 100,000 jobs were successfully enqueued over 9 minutes and 15 seconds.
  * Tried sleeping between enqueues for 0.002 seconds (2ms). 100,000 jobs were successfully enqueued over 7:07 minutes
  * Tried sleeping between queries for 0.0015 seconds (1.5ms). 100,000 jobs were successfully enqueued over between 5:48 6:14 minutes.
    * This makes sense as the amount of time it takes for both enqueueing and dequeuing side to complete while working together without any issues is around 5:40.
  * It seems that this problem is caused by our `storage.rb` where if we initalize Redis like so `@redis = ConnectionPool::Wrapper.new(size: 10, timeout: 10) { Redis.connect }`, it will error out as described above. However, if we turn it into a constant like so `REDIS_POOL = ConnectionPool::Wrapper.new(size: 10, timeout: 10) { Redis.connect }` will not.
    * Enqueueing both `JobTestFast` and `JobTestSlow` takes ~50 seconds in this case.
* Unsurprisingly, for `JobTestFast`, the amount of time it took between one worker and 25 workers is the same.
  * In fact, it was found that the time it took with one thread was 10 seconds faster than using 25 workers.
    * 1:27 with one worker vs. 1:40 with 25 workers
    * This could be due to the cost of context switching or may be within a margin of error.
* However, for out `JobTestSlow`, an IO blocking job, the time it would've potentially taken with one worker would be 0.5s * 100,000 = 50,000 seconds.
  * Instead of waiting that long, I ran the job 1000 times and it took 8:24. Multiply that 100 times and this job would have taken 50,400 seconds.
* Connection pool does not want seem to have an effect.
* When creating a dangerous job, more specifically, a job that makes a call to kill the main thread. The job just errors out and

Large argument jobs:
* Enqueueing ended up taking forever for 100,000 jobs. Dropped to 10,000 in interest of time
  * Takes ~20 minutes to enqueue something that uses an array with 10,000 elements.
  * This large enqueuing time may be attributed to the serialization of this many elements.
