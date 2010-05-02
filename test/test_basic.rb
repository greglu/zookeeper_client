#$LOAD_PATH << '/home/eric/zk-clients/lib'
require 'rubygems'

$LOAD_PATH.unshift( File.join(File.dirname(__FILE__), "..", "lib") )
require 'zookeeper_jruby'

z = Zookeeper.new("localhost:2181")

puts "root: #{z.get_children("/").inspect}"

path = "/testing_node"

puts "working with path #{path}"

stat = z.stat(path)
puts "exists? #{stat.inspect}"

unless stat.nil?
  z.get_children(path).each do |o|
    puts "  child object: #{o}"
  end
  puts "delete: #{z.delete(path, stat.version).inspect}"
end

puts "create: #{z.create(path, "initial value", Zookeeper::EPHEMERAL).inspect}"

value, stat = z.get(path)
puts "current value #{value}, stat #{stat.inspect}"

puts "set: #{z.set(path, "this is a test", stat.version).inspect}"

value, stat = z.get(path)
puts "new value: #{value.inspect} #{stat.inspect}"

puts "delete: #{z.delete(path, stat.version).inspect}"

#begin
#  puts "exists? #{z.exists(path)}"
#  raise Exception, "it shouldn't exist"
#rescue ZooKeeper::NoNodeError
#  puts "doesn't exist - good, because we just deleted it!"
#end

puts "trying a watcher"
puts z
if s = z.stat("/test"); z.delete("/test", s.version); end
z.create("/test", "foo", Zookeeper::EPHEMERAL)
z.exists("/test")
puts "now changing it"
z.set("/test", "bar", 0)
sleep 1
puts "did the watcher say something?"

#puts "let's try using a lock"
#z.try_acquire("/test_lock", "this is the content of the lock file") do |have_lock|
#  puts have_lock ? "we have the lock!" : "failed to obtain lock :("
#  if have_lock
#    puts "sleeping"
#    sleep 5
#  end
#end
puts "done with locking..."

