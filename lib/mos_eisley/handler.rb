require 'url_signer'

class MosEisley
  class Handler < Mongrel::HttpHandler
    attr_reader :access_logger, :application_logger
    # TODO: Secret key in config file verschieben
    URL_SIGNER = UrlSigner.new("h5h56j675j*!f$uipojf%")
    
    def initialize(adapter,access_logger = Logger.new(STDOUT), application_logger = Logger.new(STDOUT) )
      self.adapter = adapter
      self.access_logger = access_logger
      self.application_logger = application_logger
    end

    def process(request, response)
      begin
        parsed_path = parse_and_validate_path(request.params)
        image = Image.new(parsed_path.image_id, parsed_path.dimension, adapter)
        if image.file_data
          ImageResizer::ResizeGenerator.resize(image) if parsed_path.resize_to
          response.start(200) do |head,out|
            head["Content-Type"] = "image/jpeg"
            head["ETag"] = %Q{"#{image.etag}"}
            head["Last-Modified"] = Time.now.to_formatted_s(:rfc822)
            head["Expires"] = image.expires_at.to_formatted_s(:rfc822)
            image.file_data.rewind
            out.write(image.file_data.read)
          end
        else
          self.application_logger.error("[#{Time.now.strftime("%d/%b/%Y:%H:%M:%S %Z")}] Could not find file for key: #{image.persistence_key}")
          respond_with_404(response)
        end
      rescue MosEisley::Exceptions::InvalidPath, MosEisley::Exceptions::PathParseError => e
        respond_with_404(response, e)
      ensure
        self.access_logger.info("#{request.params['REMOTE_ADDR']} - - [#{Time.now.strftime("%d/%b/%Y:%H:%M:%S %Z")}] \"#{request.params['REQUEST_METHOD']} #{request.params['REQUEST_URI']} #{request.params['SERVER_PROTOCOL']}\" #{response.status} #{response.body.size}")
      end
    end

    private

    attr_accessor :adapter
    
    attr_writer :access_logger
    attr_writer :application_logger
        
    class ParsedPath
      attr_accessor :image_id, :resize_to, :seo

      def self.signer
        @@signer
      end
      def initialize(image_id, resize_to, seo)
        self.image_id = image_id
        self.resize_to = resize_to
        self.seo = seo
      end

      def dimension
        return nil unless self.resize_to.respond_to?(:split)
        width,height = self.resize_to.split("x")
        if width && height
          return ImageResizer::Dimension.new(width.to_i,height.to_i)
        else
          return nil
        end
      end
  
    end

    def parse_and_validate_path(params)
      complete_url = URI::HTTP.build(:host => params["SERVER_NAME"], :port => params["SERVER_PORT"], :path => params["PATH_INFO"]).to_s
      if URL_SIGNER.valid?(complete_url)
        unsigned_url = URL_SIGNER.unsign(complete_url)
      else
        raise MosEisley::Exceptions::InvalidPath, "The url #{complete_url} is invalid, wrong signature"
      end

      parsed_path = parse_path(URI.parse(unsigned_url).path)
      return parsed_path 
    end

    def parse_path(path)
      # TODO: Moeglichen Endungen in config file verschieben
      match = path.match(/^\/(.+)\-(\d+)(?:\-(\d+x\d+))?\.jpg$/)
      unless match.nil?
        image_id = match[2]
        resize_to = match[3]
        seo = match[1]
        return ParsedPath.new(image_id, resize_to, seo)
      else
        raise MosEisley::Exceptions::PathParseError, "The path #{path} could not be parsed"
      end
    end

    def respond_with_404(response, exception = nil)
      response.start(404) do |head,out|
        head["Content-Type"] = "text/plain"
        out.write("404 - Resource not found")
        out.write("#{exception}") if exception
      end
    end

  end
end