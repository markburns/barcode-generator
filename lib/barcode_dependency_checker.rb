class BarcodeDependencyChecker
  class ImageMagickMissingException < StandardError;end
  class GhostScriptMissingException < StandardError;end
  class GhostScriptToPngConversionFailed < StandardError;end
  class BarcodeDirectoryDoesNotExist < StandardError; end
  PASSENGER_WARNING = "\n If you have passenger installed then you may need to ammend the path environment variable in apache config"

  def self.check_image_magick
    convert_filename = `which convert`
    if convert_filename.blank?
      raise ImageMagickMissingException, "You must have imagemagick installed to generate barcodes." + PASSENGER_WARNING
    end
  end

  def self.check_ghost_script
    gs_filename = `which gs`
    if gs_filename.blank?
      raise GhostScriptMissingException, "You must have ghostscript installed to generate barcodes" + PASSENGER_WARNING
    end
  end



  def self.check_image_path
    dir = BarcodeGenerator::BARCODE_IMAGES_PATH
    unless File.exists? dir
      raise BarcodeDependencyChecker::BarcodeDirectoryDoesNotExist, "You must create a directory: #{dir}"
    end
  end

  def self.check_dependencies
    check_image_magick
    check_ghost_script
    check_image_path
  end
end
