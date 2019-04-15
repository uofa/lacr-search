class XmlUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    "uploads/xml/"
  end

  def extension_whitelist
    %w(xml)
  end

  def content_type_whitelist
      ['application/xml', 'text/xml']
  end
end
