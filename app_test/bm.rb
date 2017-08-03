require 'benchmark'

class FibCruncher
  def self.perform(n)
    a, b = 0, 1
    while b < n
      a, b = b, a + b
    end
    b
  end
end

def run_benchmark(n)
  Benchmark.bm do |r|
    r.report do
      n.times do
        FibCruncher.perform(1_000)
      end
    end

    r.report do
      n.times do
        FibCruncher.perform(1_000_00)
      end
    end

    r.report do
      n.times do
        FibCruncher.perform(1_000_000)
      end
    end

    r.report do
      n.times do
        FibCruncher.perform(1_000_000_0)
      end
    end

    r.report do
      n.times do
        FibCruncher.perform(1_000_000_000)
      end
    end
  end
end
