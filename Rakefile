# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/osx'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'THLHelper'
  app.frameworks = %w(AppKit Foundation CoreGraphics ScriptingBridge)
  app.info_plist['LSUIElement'] = true
  app.copyright = "Copyright (c) #{Time.now.year} #{ENV['USER']}"
end
