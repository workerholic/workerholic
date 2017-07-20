TEST_QUEUE = 'workerholic:test:queue'
TEST_SCHEDULED_SORTED_SET = 'workerholic:test:scheduled_jobs'

def expect_during(duration_in_secs, target)
  timeout = Time.now.to_f + duration_in_secs

  while Time.now.to_f <= timeout
    result = yield
    return if result == target

    sleep(0.001)
  end

  expect(result).to eq(target)
end
