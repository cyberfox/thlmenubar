class AppDelegate
  attr_accessor :menubar

  def applicationDidFinishLaunching(notification)
    @menubar = THLMenuBar.new

    NSTimer.scheduledTimerWithTimeInterval(300, target: @menubar, selector: 'refresh:', userInfo: nil, repeats: true)
  end
end
