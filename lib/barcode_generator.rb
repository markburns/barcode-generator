# BarcodeGenerator
# uses Gbarcode for encoding barcode data and then rmagick to generate
# images out of it for displaying in views.

# i was using clumsy file.new and file.close for eps generation, but 
# Adam Feuer had published a much elegant way by using IO.pipe for doing
# same thing. (never occured to me !! :-P )

# this way we can generate any barcode type which Gbarcode -> Gnome Barcode project
# supports.

# Extending <tt>ActionView::Base</tt> to support rendering themes
require 'imagemagick_wrapper'
module ActionView
  # Extending <tt>ActionView::Base</tt> to support rendering themes
  class Base
    include ImageMagickWrapper

    VALID_BARCODE_OPTIONS = [:encoding_format, :output_format, :width, :height, :scaling_factor, :xoff, :yoff, :margin, :resolution, :antialias	]
    
    def barcode(id, options = {:encoding_format => DEFAULT_ENCODING })

      options.assert_valid_keys(VALID_BARCODE_OPTIONS)
      output_format = options[:output_format] ? options[:output_format] : BarcodeGenerator::DEFAULT_FORMAT

      id.upcase!
      dir = BarcodeGenerator::BARCODE_IMAGES_PATH
      eps = File.join(dir,"#{id}.eps")
      out = File.join(dir,"#{id}.#{output_format}")
      
      #dont generate a barcode again, if already generated
      unless File.exists?(out)
        #generate the barcode object with all supplied options
        options[:encoding_format] = BarcodeGenerator::DEFAULT_ENCODING unless options[:encoding_format]
        bc = Gbarcode.barcode_create(id)
        bc.width  = options[:width]          if options[:width]
        bc.height = options[:height]         if options[:height]
        bc.scalef = options[:scaling_factor] if options[:scaling_factor]
        bc.xoff   = options[:xoff]           if options[:xoff]
        bc.yoff   = options[:yoff]           if options[:yoff]
        bc.margin = options[:margin]         if options[:margin]
        Gbarcode.barcode_encode(bc, options[:encoding_format])
        
        if options[:no_ascii]
          print_options = Gbarcode::BARCODE_OUT_EPS|Gbarcode::BARCODE_NO_ASCII
        else
          print_options = Gbarcode::BARCODE_OUT_EPS
        end
        
        #encode the barcode object in desired format
        File.open(eps,'wb') do |eps_img| 
          Gbarcode.barcode_print(bc, eps_img, print_options)
          eps_img.close
          success = convert_to_png(eps, out, options[:resolution], options[:antialias])
          unless success
            raise BarcodeDependencyChecker::GhostScriptToPngConversionFailed
          end
        end
        
        #delete the eps image, no need to accummulate cruft
        File.delete(eps)
      end
      #send the html image tag
      image_tag("/barcodes/#{id}.#{output_format}")
    end
    
  end
end
