# Eneroth Scale Tool Handles

# Copyright Julia Christina Eneroth, eneroth3@gmail.com

require "sketchup.rb"
require "extensions.rb"

module EneScaleToolHandles

  PLUGIN_ID = File.basename(__FILE__, ".rb")
  PLUGIN_DIR = File.join(File.dirname(__FILE__), PLUGIN_ID)

  EXTENSION = SketchupExtension.new(
    "Eneroth Scale Tool Handles",
    File.join(PLUGIN_DIR, "main")
  )
  EXTENSION.creator     = "Julia Christina Eneroth"
  EXTENSION.description =
    "Simplified interface to set what scale tool handles component has."
  EXTENSION.version     = "1.0.0"
  EXTENSION.copyright   = "#{EXTENSION.creator} 2017"
  Sketchup.register_extension(EXTENSION, true)

end
