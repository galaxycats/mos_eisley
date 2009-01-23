require File.dirname(__FILE__) + "/test_helper"

class ImageTest < Test::Unit::TestCase
  
  def test_should_implement_persistable_interface
    dimension = mock("Dimension")
    adapter = stub_everything("DummyAdapter")
    
    image = MosEisley::Image.new("some_key", dimension,adapter)
    
    file_data = StringIO.new("Hans Wurst")
    
    image.expects(:file_data)
    image.expects(:file_data=).with(file_data)
    
    assert_equal "some_key", image.persistence_key
    image.persistence_data
    image.persistence_data = file_data
  end
  
  def test_should_implement_resizeable_interface
    dimension = mock("Dimension")
    adapter = stub_everything("DummyAdapter")
    
    image = MosEisley::Image.new("some_key", dimension, adapter)
    
    assert_equal dimension, image.dimension
    
    file_data = StringIO.new("lalala")
    image.expects(:file_data).returns(file_data)
    assert_equal file_data, image.image_data
    image.expects(:file_data=).with(file_data)
    image.image_data = file_data
  end
  
  def test_should_initialize_image_with_key_size_and_data_from_adapter
    dimension = mock("Dimension")
    adapter = mock("DummyAdapter")

    adapter.expects(:read).with(instance_of(MosEisley::Image))

    image = MosEisley::Image.new("some_key", dimension,adapter)    
        
    assert_equal "some_key", image.instance_variable_get("@image_id")
    assert_equal dimension, image.instance_variable_get("@dimension")
  end
      
end