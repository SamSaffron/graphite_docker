require 'statsd-ruby'

$s = Statsd.new 'localhost', 8125


i = 100
while true
  sleep 1

  i += 1
  $s.gauge 'memory.server1', i

  100.times do
    $s.timing 'duration.server1', (Random.rand * 100)
  end
end


