class MosEisley
  class Image
  
    attr_reader :dimension
    attr_reader :image_id
    attr_reader :file_data
  
    def initialize(image_id, dimension, adapter)
      self.image_id  = image_id
      self.dimension = dimension
      adapter.read(self)
    end
    
    def etag
      file_data.rewind
      "#{Digest::MD5.hexdigest(file_data.read)}-#{self.image_id}"
    end
    
    def expires_at
      Time.now + 2.month
    end
  
    def image_data
      self.file_data
    end
    
    def image_data=(image_data)
      self.file_data = image_data
    end
  
    def persistence_key
      self.image_id
    end
  
    def persistence_data
      self.file_data
    end
  
    def persistence_data=(data)
      self.file_data = data
    end
    
    # TODO: fix "private attribute?" warnings, use instance variable instead of attr_writer
    
    private
  
      attr_writer :image_id
      attr_writer :dimension
      attr_writer :file_data
  
  end
end