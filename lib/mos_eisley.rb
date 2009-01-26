$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "rubygems"
require "mongrel"
require "renum"
require "image_resizer"
require "persistable"
require "mos_eisley/exceptions"
require "mos_eisley/handler"
require "mos_eisley/image"
require 'active_support'

class MosEisley
  VERSION = '0.3.2'
  ADAPTER_YML_PATH = "adapter.yml"
  MONGREL_YML_PATH = "mongrel.yml"
  
  DEFAULT_ADAPTER_CONFIG = {
    :adapter => {
      :type => "memory"
    }
  }
  DEFAULT_MONGREL_CONFIG = {
    :host => "0.0.0.0",
    :port => "3324"
  }
  
  attr_reader :logger
  
  def initialize(options = {})
    options.symbolize_keys!
    set_mongrel_config(options)
    set_adapter(options)
  end
  
  def run
    puts "** Starting Mongrel listening at #{mongrel_config[:host]}:#{mongrel_config[:port]}"
    mongrel_http_server = Mongrel::HttpServer.new(mongrel_config[:host], mongrel_config[:port])
    puts "** Registering MosEisley (Version #{VERSION})"
    puts "** Using #{adapter.class.name}"
    mongrel_http_server.register("/", MosEisley::Handler.new(adapter))
    LOGGER.debug("Mongrel MosEisley started")
    LOGGER.debug("Using #{adapter.class.name}")
    LOGGER.debug("FSAdapter StorageLocation: #{adapter.storage_location}") if adapter.class == Persistable::FSAdapter
    mongrel_http_server.run.join
  end
    
  def load_mongrel_config
    load_yml(MONGREL_YML_PATH, DEFAULT_MONGREL_CONFIG)
  end
  
  def set_adapter(options = {})
    self.adapter = Persistable::Factory.build(options[:adapter_config_path] || ADAPTER_YML_PATH, DEFAULT_ADAPTER_CONFIG)
  end

  def set_mongrel_config(options = {})
    options.symbolize_keys!
    self.mongrel_config = load_mongrel_config
    mongrel_config.merge!(:port => options[:port]) if options[:port]
    mongrel_config.merge!(:address => options[:address]) if options[:address]
  end
  
  def load_yml(filepath, default={})
    File.open(filepath) do |f|
      default.merge(YAML.load_file(f))
    end if File.exists?(filepath)
    default
  end
  
  def daemonize
    exit if fork                   # Parent exits, child continues.
    Process.setsid                 # Become session leader.
    exit if fork                   # Zap session leader. See [1].
    Dir.chdir "/"                  # Release old working directory.
    File.umask 0000                # Ensure sensible umask. Adjust as needed.
    STDIN.reopen "/dev/null"       # Free file descriptors and
    STDOUT.reopen "/dev/null", "a" # point them somewhere sensible.
    STDERR.reopen STDOUT           # STDOUT/ERR should better go to a logfile.
    trap("TERM") { exit }
  end
  
  private
    
    attr_accessor :mongrel_config, :adapter
  
end