require "test_helper"

class MongrelMosEisleyTest < Test::Unit::TestCase
  
  def test_should_start_mongrel_http_server_and_register_moseisley_handler
    mos_eisley = mock("mos_eisley_mock")
    mos_eisley.expects(:run)
    MosEisley.expects(:new).returns(mos_eisley)

    load File.dirname(__FILE__) + "/../bin/mongrel_mos_eisley"
  end
  
end