--
-- Selection window
--
SelectionWindow = {}
SelectionWindow.__index = SelectionWindow

local screenWidth, screenHeight = guiGetScreenSize()

function createSelectionWindow(callback)
    local self = setmetatable({}, SelectionWindow)
    self.callback = callback
    self.visible = false
    self.width = 280
    self.height = 55

    local gui = {}
    self.gui = gui
    
    local x = (screenWidth - self.width) / 2
    local y = 0
    gui.window = guiCreateWindow(x, y, self.width, self.height, "Select a GUI element with 'right click'", false)
    guiSetProperty(gui.window, "CloseButtonEnabled", "False")
    guiSetProperty(gui.window, "AlwaysOnTop", "True")
    guiWindowSetSizable(gui.window, false)
    guiSetVisible(gui.window, false)

    gui.closeButton = guiCreateButton(10, 25, 20, 20, "x", false, gui.window)
    addEventHandler("onClientGUIClick", gui.closeButton, bind(self, self.hide))

    gui.placeholderText = "[Move your cursor above an enabled GUI element]"
    gui.hoverLabel = guiCreateLabel(40, 29, self.width - 50, 15, gui.placeholderText, false, gui.window)
    guiSetFont(gui.hoverLabel, "default-small")

    self.handlers = {}
    self.handlers.onEnter = bind(self, self._onEnter)
    self.handlers.onLeave = bind(self, self._onLeave)
    self.handlers.onClick = bind(self, self._onClick)
    
    return self
end

--
-- Public
--
function SelectionWindow:show()
    if not self.visible then
        showCursor(true)
        guiSetVisible(self.gui.window, true)
        guiBringToFront(self.gui.window)
        addEventHandler("onClientMouseEnter", root, self.handlers.onEnter)
        addEventHandler("onClientMouseLeave", root, self.handlers.onLeave)
        addEventHandler("onClientGUIClick", root, self.handlers.onClick)
        self.visible = true
    end
end

function SelectionWindow:hide()
    if self.visible then
        showCursor(false)
        guiSetVisible(self.gui.window, false)
        removeEventHandler("onClientMouseEnter", root, self.handlers.onEnter)
        removeEventHandler("onClientMouseLeave", root, self.handlers.onLeave)
        removeEventHandler("onClientGUIClick", root, self.handlers.onClick)
        self.visible = false
    end
end

function SelectionWindow:toggle()
    if self.visible then
        self:hide()
    else
        self:show()
    end
end

function SelectionWindow:destroy()
    if self.visible then
        self:hide()
    end

    destroyElement(self.gui.window)
    setmetatable(self, nil)
    for k in pairs(self) do self[k] = nil end
end

--
-- Private
--
function SelectionWindow:_onEnter()
    if hasElementAsParent(source, self.gui.window) then
        guiSetText(self.gui.hoverLabel, self.gui.placeholderText)
    else
        local text = guiGetText(source)
        text = text:sub(1, math.min(128, text:len()))
        guiSetText(self.gui.hoverLabel, ("%s – [%s] %s"):format(
            guiGetResourceName(source), 
            getElementType(source), 
            text
        ))
    end
end

function SelectionWindow:_onLeave(_, _, element)
    if element == nil then
        guiSetText(self.gui.hoverLabel, self.gui.placeholderText)
    end
end

function SelectionWindow:_onClick(button, state)
    if button ~= "right" or state ~= "up" then
        return
    end

    if hasElementAsParent(source, self.gui.window) then
        return
    end

    if self.callback then
        self.callback(source)
    end
end
