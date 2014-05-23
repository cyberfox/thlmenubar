class TaskMenuItem < Struct.new(:menu_item, :task, :url)
end

class THLMenuBar
  attr_accessor :hitlist

  # Construct the menu bar helper.
  #
  # Potential configuration/expansion points include:
  #   Default sort (currently :title)
  #   Maximum number of tasks to show
  #   What actions to perform?
  #   Activate The Hit List before browsing to the task URL?
  #   Use a different list than 'today'
  def initialize
    @hitlist = SBApplication.applicationWithBundleIdentifier("com.potionfactory.TheHitList")

    @sort_by = :title
    @maximum_tasks = 5
    @task_menu = {}

    @status_item = NSStatusBar.systemStatusBar.statusItemWithLength(NSVariableStatusItemLength).init.tap do |menubar|
      menubar.setMenu menu
      menubar.setImage(NSImage.imageNamed('status_black.png'))
      menubar.setHighlightMode(true)
    end

    refresh
  end

  # Refresh menu entry; gets any new tasks, puts them in the menu, and
  # fixes up the menubar entry itself to reflect the new state.
  def refresh(sender = nil)
    new_tasks = tasks

    render_tasks(new_tasks)
    render_menubar(new_tasks)
  end

  # Selecting a task in the menu triggers this.  The tasks have their
  # IDs stored as representedObjects, and so can be looked up that way.
  def show(sender)
    #@hitlist.activate
    NSWorkspace.sharedWorkspace.openURL(NSURL.URLWithString(@task_menu[sender.representedObject].url))
    `osascript -e 'tell application "System Events" to keystroke "2" using {command down}'`
    sleep 0.1
    `osascript -e 'tell application "System Events" to keystroke "b"'`
    # `osascript -e 'tell application "Pomodoro" to start "#{sender.title}" duration 25'`
  end

  # Selecting between priority and title sort; relies on the preferred
  # sorting order being stored as a represented object on the menuitem.
  def choose_sort(sender)
    set_states(@sort_by = sender.representedObject)
    refresh
  end

  # Exit the application
  def quit(sender)
    NSApplication.sharedApplication.terminate(self)
  end

  private
  def menu
    @menu ||= NSMenu.new.tap do |menu|
      menu.initWithTitle 'The Hit List'
      menu.addItem NSMenuItem.separatorItem
      menu.addItem createMenuItem('About', 'orderFrontStandardAboutPanel:', nil)

      menu.addItem NSMenuItem.separatorItem

      @titlesort_item = createMenuItem('Sort by title', 'choose_sort:')
      @titlesort_item.setRepresentedObject(:title)
      @priosort_item = createMenuItem('Sort by priority', 'choose_sort:')
      @priosort_item.setRepresentedObject(:priority)

      # This should pull from the app configuration, for the first-time startup.
      set_states(@sort_by)

      menu.addItem(@titlesort_item)
      menu.addItem(@priosort_item)

      menu.addItem NSMenuItem.separatorItem

      menu.addItem createMenuItem('Refresh', 'refresh:')
      menu.addItem createMenuItem('Quit', 'quit:')
    end
  end

  def set_states(sort_by)
    is_title = sort_by == :title
    @titlesort_item.state = is_title ? NSOnState : NSOffState
    @priosort_item.state = !is_title ? NSOnState : NSOffState
  end

  def createMenuItem(name, action, target=self)
    NSMenuItem.alloc.initWithTitle(name, action: action, keyEquivalent: '').tap do |item|
      item.target = target unless target.nil?
    end
  end

  # Return the list of incomplete tasks for today, to a maximum of 5.
  #
  # Rubymotion note: Uses #properties['completed'] instead of
  # #completed because the ScriptingBridge defines methods as
  # returning objects, and #completed returns a boolean directly.  I
  # believe it would need to be specially precompiled to be correctly
  # recognized.  (ibid for 'canceled'.)
  def tasks
    @hitlist.todayList.tasks.select do |task|
      !task.properties['completed'] && !task.properties['canceled']
    end.sort_by(&@sort_by)[0..@maximum_tasks]
  end

  def render_tasks(new_tasks)
    @task_menu.each { |_, tmi| @menu.removeItem tmi.menu_item }
    @task_menu.clear

    tasks.each do |task|
      item = createMenuItem(task.title, 'show:')
      item.setRepresentedObject(task.id)

      @menu.insertItem item, atIndex: @task_menu.length
      @task_menu[task.id] = TaskMenuItem.new(item, task, task.url)
    end
  end

  def menubar_information(count)
    count > 0 ? [count.to_s, 'color'] : [nil, 'black']
  end

  def render_menubar(new_tasks)
    title, menubar_color = menubar_information(new_tasks.size)
    @status_item.setImage(NSImage.imageNamed("status_#{menubar_color}.png"))
    @status_item.setAttributedTitle(title)
  end
end
