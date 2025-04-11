-- This file is part of Hammerspoon and uses the hs global variable
-- luacheck: globals hs

-- Function to center a given window
function centerWindow(win)
    if not win then
        return
    end

    local screen = win:screen()
    local frame = screen:frame()
    
    -- Calculate the center position
    local width = win:frame().w
    local height = win:frame().h
    local x = frame.x + (frame.w - width) / 2
    local y = frame.y + (frame.h - height) / 2

    -- Set the new frame of the window
    win:setFrame(hs.geometry.rect(x, y, width, height))
end

-- Function to center newly created windows
function centerNewWindow(win)
    if win then
        centerWindow(win)
    end
end

-- Watch for new windows and center them
hs.window.filter.new():subscribe(hs.window.filter.windowCreated, centerNewWindow)

-- Optional: Center existing windows on startup
hs.timer.doAfter(1, function()
    local allWindows = hs.window.allWindows()
    for _, win in ipairs(allWindows) do
        centerWindow(win)
    end
end)

-- Function to launch applications and center the window
function launchAndCenter(appName)
    local app = hs.application.launchOrFocus(appName)
    hs.timer.doAfter(1, function() -- Increased delay to allow more time for the window to appear
        local windows = app:allWindows()
        if #windows > 0 then
            centerWindow(windows[1]) -- Center the first window found
        else
            hs.alert.show(appName .. " has no windows!")
        end
    end)
end

-- Key bindings
hs.hotkey.bind({"ctrl", "shift"}, "s", function() launchAndCenter("Slack") end)
hs.hotkey.bind({"ctrl", "shift"}, "f", function() launchAndCenter("Firefox") end)
hs.hotkey.bind({"ctrl", "shift"}, "t", function() launchAndCenter("iTerm") end)
hs.hotkey.bind({"ctrl", "shift"}, "z", function() launchAndCenter("zoom.us") end)
hs.hotkey.bind({"ctrl", "shift"}, "r", function() launchAndCenter("Reminders") end)

hs.alert.show("Hammerspoon configuration loaded: Auto-centering windows enabled")
