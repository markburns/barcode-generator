module BarcodeGenerator
  DEFAULT_ENCODING = Gbarcode::BARCODE_39 | Gbarcode::BARCODE_NO_CHECKSUM
  DEFAULT_FORMAT = 'png'
  BARCODE_IMAGES_PATH = Rails.root.join('public', 'barcodes') 
end
