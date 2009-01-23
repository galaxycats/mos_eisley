require "test_helper"

class MosEisleyTest < Test::Unit::TestCase
  
  def test_should_start_mongrel_http_server_and_register_moseisley_handler
    # allocate creates an object without calling initialize
    mos_eisley = MosEisley.allocate
    mos_eisley.expects(:mongrel_config).at_least(2).returns({:host => "0.0.0.0", :port => "3324"})
    mos_eisley_handler = mock("mock_mos_eisley_handler")
    MosEisley::Handler.expects(:new).returns(mos_eisley_handler)
    mongrel_http_server = mock("mongrel_http_server_mock")
    mongrel_http_server.expects(:register).with("/", mos_eisley_handler)
    mongrel_http_server.expects(:run).returns(mock("ObjectToCallJoinOn", :join => true))
    Mongrel::HttpServer.expects(:new).with("0.0.0.0", "3324").returns(mongrel_http_server)
    mos_eisley.expects(:adapter).at_least_once.returns(mock("adapter"))
    
    mos_eisley.run
  end
  
  def test_should_load_yml_from_filename
    # allocate creates an object without calling initialize
    mos_eisley = MosEisley.allocate
    file_mock = mock("File_mock")
    File.expects(:exists?).returns(true)
    File.expects(:open).with("adapter.yml").yields(file_mock)
    YAML.expects(:load_file).with(file_mock).returns({})
    mos_eisley.load_yml("adapter.yml")
  end
  
  def test_should_just_return_defaults_in_load_yml_if_file_does_not_exist
    # allocate creates an object without calling initialize
    mos_eisley = MosEisley.allocate
    file_mock = mock("File_mock")
    File.expects(:exists?).returns(false)
    defaults = mock("defaults")
    loaded_config = mos_eisley.load_yml("adapter.yml", defaults)
    assert_equal defaults, loaded_config
  end
  
  def test_should_set_adapter
    # allocate creates an object without calling initialize
    mos_eisley = MosEisley.allocate
    adapter_mock = mock("adapter_mock")
    Persistable::Factory.expects(:build).with(MosEisley::ADAPTER_YML_PATH, MosEisley::DEFAULT_ADAPTER_CONFIG).returns(adapter_mock)
    mos_eisley.expects(:adapter=).with(adapter_mock)
    mos_eisley.set_adapter
  end
  
  def test_should_initialize_with_mongrel_config_and_adapter
    MosEisley.any_instance.expects(:load_mongrel_config)
    MosEisley.any_instance.expects(:set_adapter)
    MosEisley.new
  end
  
  def test_should_should_load_mongrel_config
    mos_eisley = MosEisley.allocate
    mos_eisley.expects(:load_yml).with("mongrel.yml", MosEisley::DEFAULT_MONGREL_CONFIG)
    mos_eisley.load_mongrel_config
  end
  
  def test_should_should_not_load_mongrel_config_if_options_hash_with_port_and_address_is_given
    mos_eisley = MosEisley.allocate
    mos_eisley.expects(:load_yml).with("mongrel.yml", MosEisley::DEFAULT_MONGREL_CONFIG).returns({})
    mos_eisley.set_mongrel_config({"port" => "1376", :address => "123.456.789.1"})
    MosEisley.publicize_methods do
      assert_equal "1376", mos_eisley.mongrel_config[:port]
      assert_equal "123.456.789.1", mos_eisley.mongrel_config[:address]
    end
  end
  
  def test_should_use_mongrel_config
    mos_eisley = MosEisley.allocate
    http_server = mock("http_server")
    mos_eisley.expects(:mongrel_config).at_least(2).returns({:host => "1.2.3.4", :port => "3344"})
    Mongrel::HttpServer.expects(:new).with("1.2.3.4", "3344").returns(http_server)
    mos_eisley.expects(:adapter).at_least_once
    http_server.expects(:register)
    MosEisley::Handler.expects(:new).returns(stub_everything)
    http_server.expects(:run).returns(mock("ObjectToCallJoinOn", :join => true))
    mos_eisley.run
  end
  
  def test_should_accept_options_hash_in_initializer
    MosEisley.any_instance.expects(:load_mongrel_config)
    MosEisley.any_instance.expects(:set_adapter)
    MosEisley.new({:some => :options})
  end
  
  def test_should_accept_port_and_address_options_hash_in_initializer
    MosEisley.any_instance.expects(:set_adapter)
    mos_eisley = MosEisley.new({"port" => "1356", :address => "127.0.0.3"})
    MosEisley.publicize_methods do
      assert_equal "1356", mos_eisley.mongrel_config[:port]
      assert_equal "127.0.0.3", mos_eisley.mongrel_config[:address]
    end
  end
  
  def test_should_load_adapter_config_from_options
    mos_eisley = MosEisley.allocate
    Persistable::Factory.expects(:build).with("some_path.yml", MosEisley::DEFAULT_ADAPTER_CONFIG)
    mos_eisley.set_adapter(:adapter_config_path => "some_path.yml")
  end
  
  def test_should_pass_options_of_initialize_to_set_adapter
    MosEisley.any_instance.expects(:load_mongrel_config)
    MosEisley.any_instance.expects(:set_adapter).with(:adapter_config_path => "some_path.yml")
    mos_eisley = MosEisley.new(:adapter_config_path => "some_path.yml")
  end
  
end