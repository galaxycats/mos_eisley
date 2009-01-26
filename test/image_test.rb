require File.dirname(__FILE__) + "/test_helper"

class ImageTest < Test::Unit::TestCase
  
  def test_should_implement_persistable_interface
    dimension = mock("Dimension")
    adapter = stub_everything("DummyAdapter")
    
    image = MosEisley::Image.new("some_key", dimension, adapter)
    
    file_data = StringIO.new("Hans Wurst")
    
    image.expects(:file_data)
    image.expects(:file_data=).with(file_data)
    
    assert_equal "some_key", image.persistence_key
    image.persistence_data
    image.persistence_data = file_data
  end
  
  def test_should_know_when_to_expire
    dimension = mock("Dimension")
    adapter = stub_everything("DummyAdapter")
    image = MosEisley::Image.new("2342", dimension, adapter)
    
    time_now = Time.now
    Time.expects(:now).returns(time_now)

    assert_equal (time_now + 2.month), image.expires_at
  end
  
  def test_should_be_able_to_generate_etag
    dimension = mock("Dimension")
    adapter = stub_everything("DummyAdapter")
    
    image = MosEisley::Image.new("2342", dimension, adapter)
    
    image_file_data = mock("File")
    image_file_data.expects(:rewind)
    image_file_data.expects(:read).returns("read_data")
    image.expects(:image_id).returns("2342")
    image.expects(:file_data).times(2).returns(image_file_data)
    Digest::MD5.expects(:hexdigest).with("read_data").returns("imageMD5")
    assert_equal "imageMD5-2342", image.etag
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