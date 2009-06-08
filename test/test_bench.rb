require 'benchmark'

class JavaCode
end

n = 10000
Benchmark.bm do |x|
  x.report { n.times do; eval("JavaCode").new; end }
  x.report { n.times do; Object.const_get("JavaCode").new; end }
end
