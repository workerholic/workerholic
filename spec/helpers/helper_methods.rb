WORKERHOLIC_QUEUE_NAMESPACE = 'workerholic:queue:'

TEST_QUEUE = 'test_queue'
ANOTHER_TEST_QUEUE = 'another_test_queue'

FIRST_BALANCER_TEST_QUEUE = 'first_balancer_test_queue'
SECOND_BALANCER_TEST_QUEUE = 'second_balancer_test_queue'
THIRD_BALANCER_TEST_QUEUE = 'third_balancer_test_queue'
FOURTH_BALANCER_TEST_QUEUE = 'fourth_balancer_test_queue'

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
