include Java
Dir["/home/greg/Code/zookeeper-3.2.2/lib/**/*.jar"].each{|f| require f}
require '/home/greg/Code/zookeeper-3.2.2/zookeeper-3.2.2.jar'

java_import 'org.apache.zookeeper.ZooKeeper'
java_import 'org.apache.zookeeper.Watcher'
java_import 'org.apache.zookeeper.data.Stat'
java_import 'org.apache.zookeeper.data.ACL'
java_import 'org.apache.zookeeper.data.Id'

class Java::OrgApacheZookeeperData::Stat
  def ctime
    Time.at(getCtime/1000)
  end

  def mtime
    Time.at(getMtime/1000)
  end
end

class ZKClient < Java::OrgApacheZookeeper::ZooKeeper
  java_import 'org.apache.zookeeper.CreateMode'

  def initialize(host)
    super(host, 10000, Watcher.new)
  end

  def exists(path)
    super(path, false)
  end

  def stat(path, &blk)
  end

  def create(path, data, createmode = CreateMode::PERSISTENT)
    id = Id.new("world", "anyone")
    acl = ACL.new(31, id)
    super(path, data.to_java_bytes, [acl], createmode)
  end

  def setData(path, data, version)
    super(path, data.to_java_bytes, version)
  end

  def getData(path)
    [String.from_java_bytes(super(path, false, stat = Java::OrgApacheZookeeperData::Stat.new)), stat]
  end
  alias_method :get, :getData

  def getChildren(path)
    super(path, false).to_a
  end
  alias_method :list, :getChildren

  def try_acquire(path, value)
  end

  def watcher(type, state, path)
  end

end

@client = ZooKeeper.new("localhost:2181", 5000, Watcher.new)
@cli = ZKClient.new("localhost:2181")