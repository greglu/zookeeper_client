include Java
#Dir["/home/greg/Code/zookeeper-3.2.2/lib/**/*.jar"].each{|f| require f}
require '/home/greg/Code/zookeeper-3.2.2/zookeeper-3.2.2.jar'

#require '/home/greg/Code/zookeeper-3.2.2/lib/log4j-1.2.15.jar'
#import org.apache.log4j.Logger
#import org.apache.log4j.PropertyConfigurator
#PropertyConfigurator.configure("/home/greg/Code/zookeeper-3.2.2/conf/log4j.properties")

java_import org.apache.zookeeper.ZooKeeper
java_import org.apache.zookeeper.Watcher
java_import org.apache.zookeeper.data.Stat

class Java::OrgApacheZookeeperData::Stat
  def ctime
    Time.at(getCtime/1000)
  end

  def mtime
    Time.at(getMtime/1000)
  end
end

class Zookeeper < Java::OrgApacheZookeeper::ZooKeeper

  java_import org.apache.zookeeper.CreateMode
  java_import org.apache.zookeeper.data.ACL
  java_import org.apache.zookeeper.data.Id

  # Zookeeper's CreateMode classes
  EPHEMERAL             = CreateMode::EPHEMERAL
  EPHEMERAL_SEQUENTIAL  = CreateMode::EPHEMERAL_SEQUENTIAL
  PERSISTENT            = CreateMode::PERSISTENT
  PERSISTENT_SEQUENTIAL = CreateMode::PERSISTENT_SEQUENTIAL

  def initialize(host)
    super(host, 10000, Watcher.new)
    @watchers = {} # path => [ block, block, ... ]
  end

  def exists(path, &blk)
    (@watchers[path] ||= []) << blk if blk
    super(path, false)
  end

  def stat(path, &blk)
    exists(path, &blk)
  end

  def create(path, data, createmode)
    raise ArgumentError,
      "createmode must be a constant from the list (#{CreateMode.constants.join(", ")})" unless createmode.is_a?(CreateMode)

    id = Id.new("world", "anyone")
    acl = ACL.new(31, id)
    super(path, data.to_java_bytes, [acl], createmode)
  end

  def setData(path, data, version)
    super(path, data.to_java_bytes, version)
  end
  alias_method :set, :setData

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
