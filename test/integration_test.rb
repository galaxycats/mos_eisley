require File.dirname(__FILE__) + "/test_helper"

require 'net/http'

class IntegrationTest < Test::Unit::TestCase
  
  def setup
    @mongrel_mos_eisley_pid = fork do
      Dir.chdir(File.dirname(__FILE__) + '/..')
      exec("ruby bin/mongrel_mos_eisley -p 3324 -a localhost -A test/assets/adapter.yml > /dev/null 2>&1")
    end
    sleep(2) # waiting for mongrel to startup
  end
  
  def test_should_process_url_and_show_image
    response_default, response_thumb, response_404 = nil, nil, nil
    
    Net::HTTP.start("localhost", "3324") do |http|
      response_default = http.get("/ingendein-seo-kram-123456_2acd9b0a43.jpg") 
      response_thumb = http.get("/ingendein-seo-kram-123456-80x64_86a122d390.jpg")
      response_404   = http.get("/irgendein-anderer-seo-kram-09897654-80x64_ca1ecc3c6d.jpg")
    end
    assert_equal "200", response_default.code
    assert_equal "200", response_thumb.code
    assert_equal "404", response_404.code
    assert_equal "image/jpeg", response_default["Content-Type"]
    assert_equal "image/jpeg", response_thumb["Content-Type"]
  end
  
  def teardown
    Process.kill(9, @mongrel_mos_eisley_pid) if @mongrel_mos_eisley_pid
  end
  
end