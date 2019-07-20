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
  app.identifier = 'com.cyberfox.THLHelper'
  app.frameworks = %w(AppKit Foundation CoreGraphics ScriptingBridge Security)
  app.info_plist['LSUIElement'] = true
  app.copyright = "Copyright (c) #{Time.now.year} #{ENV['USER']}"
  # This doesn't work because TheHitList doesn't have any access-groups.
  #  app.entitlements['com.apple.security.scripting-targets'] = {'com.potionfactory.TheHitList' => '?' }
  app.entitlements['com.apple.security.temporary-exception.apple-events'] = "com.potionfactory.TheHitList"
  app.info_plist['NSAppleEventsUsageDescription'] = 'In order to read tasks from The Hit List.'
  app.info_plist['NSAppleScriptEnabled'] = true

  # After compilation, in development mode, you must run:
  #  codesign -s - -f build/MacOSX-10.14-Development/THLHelper.app --deep
end
