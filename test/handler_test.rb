require File.dirname(__FILE__) + "/test_helper"
class MosEisley::HandlerTest < Test::Unit::TestCase
  
  def test_should_have_an_adapter_on_initialize
    adapter = mock("Adapter")
    mos_eisley_handler = MosEisley::Handler.new(adapter)
    assert_equal adapter, mos_eisley_handler.instance_variable_get("@adapter")
  end
  
  def test_should_should_not_resize_if_image_file_data_not_found
    adapter = mock("Adapter")
    mos_eisley_handler = MosEisley::Handler.new(adapter,logger=Logger.new("/dev/null"),logger)
    logfile = StringIO.new
    logger = Logger.new(logfile)
    mos_eisley_handler.expects(:access_logger).returns(logger)
    parsed_path_mock = stub("parsed_path")
    parsed_path_mock.expects(:resize_to).never
    parsed_path_mock.stubs(:image_id)
    parsed_path_mock.stubs(:dimension)
    mos_eisley_handler.expects(:parse_and_validate_path).returns(parsed_path_mock)
    image = mock("image")
    image.expects(:file_data).returns(nil)
    image.expects(:persistence_key).returns("badkey")
    MosEisley::Image.expects(:new).returns(image)
    ImageResizer::ResizeGenerator.expects(:resize).never
    response_socket = StringIO.new
    response = Mongrel::HttpResponse.new(response_socket)
    response.expects(:start).with(404)
    request = mock("Mongrel::MockHttpRequest")
    request.expects(:params).at_least_once.returns({"PATH_INFO" => "/invalid_path", "SERVER_NAME" => "localhost"})
    mos_eisley_handler.process(request, response)
  end
  
  def test_should_validate_and_parse_path
    adapter = mock("Adapter")
    mos_eisley_handler = MosEisley::Handler.new(adapter)
    UrlSigner.any_instance.stubs(:hash).returns("deadbeef00")
    MosEisley::Handler.publicize_methods do    
      parsed_and_valid_path = mos_eisley_handler.parse_and_validate_path({"PATH_INFO"  => "/toller-seo-kram-67434267-85x64_deadbeef00.jpg", "SERVER_NAME" => "images.pkw.de"})
      assert_equal "67434267", parsed_and_valid_path.image_id
      assert_equal ImageResizer::Dimension.new(85,64), parsed_and_valid_path.dimension
    end
  end
  
  def test_should_parse_path_with_size
    adapter = mock("Adapter")
    mos_eisley_handler = MosEisley::Handler.new(adapter)
    parsed_path = nil
    MosEisley::Handler.publicize_methods do
      parsed_path = mos_eisley_handler.parse_path("/ingendein-seo-kram-67434267-85x64.jpg")
    end
    assert_equal "67434267", parsed_path.image_id
    assert_equal "85x64", parsed_path.resize_to
    assert_equal "ingendein-seo-kram", parsed_path.seo
  end
  
  def test_should_parse_path_even_without_size
    adapter = mock("Adapter")
    mos_eisley_handler = MosEisley::Handler.new(adapter)
    parsed_path = nil
    MosEisley::Handler.publicize_methods do
      parsed_path = mos_eisley_handler.parse_path("/ingendein-seo-kram-67434267.jpg")
    end
    assert_equal "67434267", parsed_path.image_id
    assert_equal nil, parsed_path.resize_to
    assert_equal "ingendein-seo-kram", parsed_path.seo
  end
  
  def test_should_raise_exception_if_path_is_not_of_valid_format
    adapter = mock("Adapter")
    mos_eisley_handler = MosEisley::Handler.new(adapter)
    MosEisley::Handler.publicize_methods do
      assert_raise(MosEisley::Exceptions::PathParseError) { mos_eisley_handler.parse_path("/ingendein-seo-kram-67434267/thumb_detail_view.jpg") }
    end
  end
  
  def test_should_get_dimension_from_size
    MosEisley::Handler.publicize_methods do
      parsed_path = MosEisley::Handler::ParsedPath.new("4711", "300x225", "seo-kram")
      assert_equal ImageResizer::Dimension.new(300,225), parsed_path.dimension
    end
  end
  
  def test_should_have_no_dimension_if_size_is_invalid
    MosEisley::Handler.publicize_methods do
      parsed_path = MosEisley::Handler::ParsedPath.new("4711", "little", "seo-kram")
      assert_equal nil, parsed_path.dimension
    end
  end
  
  def test_should_return_404_if_path_is_invalid
    adapter = mock("Adapter")
    mos_eisley_handler = MosEisley::Handler.new(adapter)
    logfile = StringIO.new
    logger = Logger.new(logfile)
    mos_eisley_handler.expects(:access_logger).returns(logger)
    response = mock("Mongrel::MockHttpResponse")
    response.expects(:start).with(404)
    response.expects(:body).returns("dummybody")
    response.stubs(:status).returns("200")
    request = mock("Mongrel::MockHttpRequest")
    request.expects(:params).at_least_once.returns({"PATH_INFO" => "/invalid_path", "SERVER_NAME" => "localhost"})
    mos_eisley_handler.process(request,response)
  end
  
  def test_should_return_404_if_image_in_adapter_not_found
    adapter = mock("Adapter")
    adapter.expects(:read)
    mos_eisley_handler = MosEisley::Handler.new(adapter,logger=Logger.new("/dev/null"),logger)
    logfile = StringIO.new
    logger = Logger.new(logfile)
    mos_eisley_handler.expects(:access_logger).returns(logger)
    UrlSigner.any_instance.stubs(:hash).returns("deadbeef00")
    response = mock("Mongrel::MockHttpResponse")
    response.expects(:start).with(404)
    response.expects(:body).returns("dummybody")
    response.stubs(:status).returns("200")
    request = mock("Mongrel::MockHttpRequest")
    request.expects(:params).at_least_once.returns({"PATH_INFO" => "/valid-path-but-image-id-does-not-exist-12345_deadbeef00.jpg", "SERVER_NAME" => "localhost"})
    mos_eisley_handler.process(request,response)
  end
  
  def test_should_return_404_if_size_is_invalid
    adapter = mock("Adapter")
    mos_eisley_handler = MosEisley::Handler.new(adapter)
    logfile = StringIO.new
    logger = Logger.new(logfile)
    mos_eisley_handler.expects(:access_logger).returns(logger)
    response = mock("Mongrel::MockHttpResponse")
    response.expects(:start).with(404)
    response.expects(:body).returns("dummybody")
    response.stubs(:status).returns("404")
    request = mock("Mongrel::MockHttpRequest")
    request.expects(:params).at_least_once.returns({"PATH_INFO" => "/ingendein-seo-kram-67434267-1x1.jpg", "SERVER_NAME" => "localhost", "SERVER_PORT" => "3000"})
    mos_eisley_handler.process(request,response)
  end
  
  def test_should_deliver_image_content_if_nothing_is_wrong
    adapter = mock("Adapter")
    mos_eisley_handler = MosEisley::Handler.new(adapter)
    logfile = StringIO.new
    logger = Logger.new(logfile)
    mos_eisley_handler.expects(:access_logger).returns(logger)
    response_socket = StringIO.new
    response = Mongrel::HttpResponse.new(response_socket)
    request = mock("Mongrel::MockHttpRequest")
    UrlSigner.any_instance.stubs(:hash).returns("deadbeef00")
    dummy_params = {"PATH_INFO" => "/ingendein-seo-kram-67434267-85x64_deadbeef00.jpg", "SERVER_NAME" => "localhost"}
    request.expects(:params).at_least_once.returns(dummy_params)
    image = mock("DummyImage")
    image.expects(:etag).returns("etag_for_image")
    image.expects(:expires_at).returns(Time.parse("Mon, 23 Mar 2009 16:25:23 +0100"))
    MosEisley::Image.expects(:new).with("67434267", ImageResizer::Dimension.new(85,64), adapter).returns(image)
    ImageResizer::ResizeGenerator.expects(:resize).with(image)
    file_data = StringIO.new("ein kleines Bild, ein kleines Bild!")
    image.expects(:file_data).at_least_once.returns(file_data)
    process_response = mos_eisley_handler.process(request,response)
    response.header.out.rewind
    response.body.rewind
    assert_match(/Content\-Type\:\simage\/jpeg/, response.header.out.read)
    assert_equal "ein kleines Bild, ein kleines Bild!", response.body.read
  end
  
  def test_should_not_resize_default_image
    adapter = mock("Adapter")
    mos_eisley_handler = MosEisley::Handler.new(adapter)
    logfile = StringIO.new
    logger = Logger.new(logfile)
    mos_eisley_handler.expects(:access_logger).returns(logger)
    response_socket = StringIO.new
    response = Mongrel::HttpResponse.new(response_socket)
    request = mock("Mongrel::MockHttpRequest")
    UrlSigner.any_instance.stubs(:hash).returns("deadbeef00")
    request.expects(:params).at_least_once.returns({"PATH_INFO" => "/ingendein-seo-kram-67434267_deadbeef00.jpg", "SERVER_NAME" => "localhost"})
    image = mock("DummyImage")
    image.expects(:etag).returns("etag_for_image")
    image.expects(:expires_at).returns(Time.parse("Mon, 23 Mar 2009 16:25:23 +0100"))
    MosEisley::Image.expects(:new).with("67434267", nil, adapter).returns(image)
    ImageResizer::ResizeGenerator.expects(:resize).never
    file_data = StringIO.new("das default Bild ohne resize!")
    image.expects(:file_data).at_least_once.returns(file_data)
    process_response = mos_eisley_handler.process(request,response)
    response.header.out.rewind
    response.body.rewind
    assert_match(/Content\-Type\:\simage\/jpeg/, response.header.out.read)
    assert_equal "das default Bild ohne resize!", response.body.read
  end
  
  def test_should_set_etag_in_header_and_last_modified
    adapter = mock("Adapter")
    mos_eisley_handler = MosEisley::Handler.new(adapter)
    logfile = StringIO.new
    logger = Logger.new(logfile)
    mos_eisley_handler.expects(:access_logger).returns(logger)
    response_socket = StringIO.new
    response = Mongrel::HttpResponse.new(response_socket)
    request = mock("Mongrel::MockHttpRequest")
    request.expects(:params).at_least_once.returns({"PATH_INFO" => "/ingendein-seo-kram-67434267_deadbeef00.jpg", "SERVER_NAME" => "localhost"})
    parsed_path = mock("parsed_path_mock")
    parsed_path.expects(:resize_to).returns(false)
    parsed_path.expects(:image_id).returns("3id27")
    parsed_path.expects(:dimension)
    mos_eisley_handler.expects(:parse_and_validate_path).returns(parsed_path)
    image = mock("DummyImage")
    image.expects(:etag).returns("foomd5-3id27")
    image.expects(:expires_at).returns(Time.parse("Mon, 23 Mar 2009 16:25:23 +0100"))
    MosEisley::Image.expects(:new).returns(image)
    image_io = StringIO.new("imagefile")
    image.expects(:file_data).at_least_once.returns(image_io)
    last_modified = mock("Time")
    Time.expects(:now).returns(last_modified).at_least_once
    last_modified.expects(:to_formatted_s).with(:rfc822).returns("Fri, 23 Jan 2009 16:25:23 +0100")
    last_modified.expects(:strftime).with('%d/%b/%Y:%H:%M:%S %Z')
    process_response = mos_eisley_handler.process(request,response)
    response.header.out.rewind
    response.body.rewind
    assert_match(/ETag\:\s\"foomd5-3id27\"/, response.header.out.read)
    response.header.out.rewind
    assert_match(/Last\-Modified\:\sFri,\s23\sJan\s2009\s16\:25\:23\s\+0100/, response.header.out.read)
  end
  
  def test_should_set_expire_date
    adapter = mock("Adapter")
    mos_eisley_handler = MosEisley::Handler.new(adapter)
    logfile = StringIO.new
    logger = Logger.new(logfile)
    mos_eisley_handler.expects(:access_logger).returns(logger)
    response_socket = StringIO.new
    response = Mongrel::HttpResponse.new(response_socket)
    request = mock("Mongrel::MockHttpRequest")
    request.expects(:params).at_least_once.returns({"PATH_INFO" => "/ingendein-seo-kram-67434267_deadbeef00.jpg", "SERVER_NAME" => "localhost"})
    parsed_path = mock("parsed_path_mock")
    parsed_path.expects(:resize_to).returns(false)
    parsed_path.expects(:image_id).returns("3id27")
    parsed_path.expects(:dimension)
    mos_eisley_handler.expects(:parse_and_validate_path).returns(parsed_path)
    image = mock("DummyImage")
    image.expects(:etag).returns("foomd5-3id27")
    image.expects(:expires_at).returns(Time.parse("Mon, 23 Mar 2009 16:25:23 +0100"))
    MosEisley::Image.expects(:new).returns(image)
    image_io = StringIO.new("imagefile")
    image.expects(:file_data).at_least_once.returns(image_io)
    process_response = mos_eisley_handler.process(request,response)
    response.header.out.rewind
    response.body.rewind
    assert_match(/Expires\:\sMon,\s23\sMar\s2009\s16\:25\:23\s\+0100/, response.header.out.read)
  end
  
  def test_should_log_successful_requests
    adapter = mock("Adapter")
    mos_eisley_handler = MosEisley::Handler.new(adapter)
    logfile = StringIO.new
    logger = Logger.new(logfile)
    mos_eisley_handler.expects(:access_logger).returns(logger)
    response_socket = StringIO.new
    response = Mongrel::HttpResponse.new(response_socket)
    response.stubs(:status).returns("200")
    request = mock("Mongrel::MockHttpRequest")
    UrlSigner.any_instance.stubs(:hash).returns("deadbeef00")

    dummy_params = {"PATH_INFO" => "/ingendein-seo-kram-67434267-85x64_deadbeef00.jpg", "SERVER_NAME" => "localhost", "REQUEST_URI" => "/ingendein-seo-kram-67434267-85x64_deadbeef00.jpg", "REMOTE_ADDR" => "123.123.123.123", "REQUEST_METHOD" => "GET", "SERVER_PROTOCOL" => "HTTP/1.1"}
    request.expects(:params).at_least_once.returns(dummy_params)
    image = mock("DummyImage")
    MosEisley::Image.expects(:new).with("67434267", ImageResizer::Dimension.new(85,64), adapter).returns(image)
    ImageResizer::ResizeGenerator.expects(:resize).with(image)
    file_data = StringIO.new("ein kleines Bild, ein kleines Bild!")
    image.expects(:file_data).at_least_once.returns(file_data)
    image.expects(:etag).returns("etag_for_image")
    image.expects(:expires_at).returns(Time.parse("Mon, 23 Mar 2009 16:25:23 +0100"))
    Time.stubs(:now).returns(Time.local(2009,"jan",1,20,15,1))
    process_response = mos_eisley_handler.process(request,response)
    response.header.out.rewind
    response.body.rewind
    assert_equal "123.123.123.123 - - [01/Jan/2009:20:15:01 CET] \"GET /ingendein-seo-kram-67434267-85x64_deadbeef00.jpg HTTP/1.1\" 200 35\n", logfile.string
  end
  
  def test_should_have_loggers
    adapter = mock("Adapter")
    access_logfile = StringIO.new
    access_logger = Logger.new(access_logfile)
    application_logfile = StringIO.new
    application_logger = Logger.new(application_logfile)
    mos_eisley_handler = MosEisley::Handler.new(adapter,access_logger,application_logger)
    assert_equal application_logger, mos_eisley_handler.application_logger
    assert_equal access_logger, mos_eisley_handler.access_logger
  end
  
  def test_should_log_errors_to_application_log
    adapter = mock("Adapter")
    mos_eisley_handler = MosEisley::Handler.new(adapter)
    logfile = StringIO.new
    logger = Logger.new(logfile)
    mos_eisley_handler.expects(:access_logger).returns(logger)
    application_logfile = StringIO.new
    application_logger = Logger.new(application_logfile)
    mos_eisley_handler.expects(:application_logger).returns(application_logger)
    response_socket = StringIO.new
    response = Mongrel::HttpResponse.new(response_socket)
    response.stubs(:status).returns("200")
    request = mock("Mongrel::MockHttpRequest")
    UrlSigner.any_instance.stubs(:hash).returns("deadbeef00")

    dummy_params = {"PATH_INFO" => "/ingendein-seo-kram-67434267-85x64_deadbeef00.jpg", "SERVER_NAME" => "localhost", "REQUEST_URI" => "/ingendein-seo-kram-67434267-85x64_deadbeef00.jpg", "REMOTE_ADDR" => "123.123.123.123", "REQUEST_METHOD" => "GET", "SERVER_PROTOCOL" => "HTTP/1.1"}
    request.expects(:params).at_least_once.returns(dummy_params)
    image = mock("DummyImage")
    MosEisley::Image.expects(:new).returns(image)
    image.expects(:file_data).returns(nil)
    image.expects(:persistence_key).returns("67434267")
    Time.stubs(:now).returns(Time.local(2009,"jan",1,20,15,1))
    process_response = mos_eisley_handler.process(request,response)
    assert_equal "[01/Jan/2009:20:15:01 CET] Could not find file for key: 67434267\n", application_logfile.string
  end
  
end