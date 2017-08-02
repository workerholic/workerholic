TEST_QUEUE = 'workerholic:testing:queue:test_queue'
ANOTHER_TEST_QUEUE = 'workerholic:testing:queue:another_test_queue'
BALANCER_TEST_QUEUE = 'workerholic:testing:queue:balancer_test_queue'
ANOTHER_BALANCER_TEST_QUEUE = 'workerholic:testing:queue:another_balancer_test_queue'
TEST_SCHEDULED_SORTED_SET = 'workerholic:testing:scheduled_jobs'
HASH_TEST = 'workerholic:testing:hash_test'

def expect_during(duration_in_secs, target)
  timeout = Time.now.to_f + duration_in_secs

  while Time.now.to_f <= timeout
    result = yield
    return if result == target

    sleep(0.001)
  end

  expect(result).to eq(target)
end
