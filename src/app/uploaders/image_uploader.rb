class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  storage :file

  CarrierWave.configure do |config|
     config.ignore_processing_errors = true
  end

  # Fix By default, CarrierWave copies an uploaded file twice,
  # first copying the file into the cache, then copying the file into the store.#
  # For large files, this can be prohibitively time consuming.
  def move_to_cache
     true
   end

   def move_to_store
     true
   end

  # Generate Web version in jpeg format
  version :large do
    process :efficient_conversion => [2048,2048]
    def filename
      super.chomp(File.extname(super)) + '.jpeg' if original_filename.present?
    end
  end

  version :normal do
    process :efficient_conversion => [800,800]
    def filename
      super.chomp(File.extname(super)) + '.jpeg' if original_filename.present?
    end
  end

  def store_dir
    "uploads/image/"
  end

  def efficient_conversion(width, height)
    manipulate! do |img|
      img.format("JPEG") do |c|
        c.fuzz        "3%"
        c.trim
        c.resize      "#{width}x#{height}>"
        c.resize      "#{width}x#{height}<"
      end
      img
    end
  end

  def extension_whitelist
    %w(tiff tif)
  end

  def content_type_whitelist
      ['image/tiff', 'image/tiff-fx']
  end
end
