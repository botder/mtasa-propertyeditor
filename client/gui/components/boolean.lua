--
-- Component: Boolean
--
local Component = {}
Component.__index = Component

local function createComponent(propertyName)
    local self = setmetatable({}, Component)
    self.propertyName = propertyName
    self.gui = false
    self.visible = true
    self.element = false
    self.x = -1
    self.y = -1
    self.parent = false
    return self
end
createComponentFactory("Boolean", createComponent)

--
-- Public
--
function Component:setElement(element)
    if self.element == element then
        return
    end

    self.element = element

    if self.gui then
        self:refresh()
    end
end

function Component:refresh()
    if not self.gui then
        return
    end

    local gui = self.gui
    local enabled = guiGetProperty(self.element, self.propertyName) == "True"
    
    if gui.enabled == enabled then
        return
    end

    gui.enabled = enabled
    guiSetText(gui.toggle_btn, enabled and "On" or "Off")

    if enabled then
        guiButtonSetColor(gui.toggle_btn, 100, 255, 100)
    else
        guiButtonSetColor(gui.toggle_btn, 255, 100, 100)
    end
end

function Component:render(x, y, width, parent)
    if not self.gui then
        -- Create GUI for the first time
        self:_createGUI(x, y, width, parent)
        return
    end

    if self.parent and self.parent ~= parent then
        -- Parent has changed, delete everything
        self:_destroyGUI()
        self:_createGUI(x, y, width, parent)
        return
    end

    if self.x ~= x or self.y ~= y then
        -- Component must be moved
        self:_moveGUI(x, y, width)
        return
    end
end

function Component:getHeight()
    return self.gui and 30 or 0
end

function Component:show()
    if not self.visible then
        self.visible = true
        self:_updateGUIVisibility()
    end
end

function Component:hide()
    if self.visible then
        self.visible = false
        self:_updateGUIVisibility()
    end
end

function Component:isVisible()
    return self.visible
end

--
-- Private
--
function Component:_createGUI(x, y, width, parent)
    if self.gui then
        return
    end

    local gui = {}
    local half_width = width / 2

    gui.label = guiCreateLabel(x, y + 2, half_width, 20, self.propertyName, false, parent)
    guiSetFont(gui.label, "clear-normal")

    gui.enabled = guiGetProperty(self.element, self.propertyName) == "True"
    gui.toggle_btn = guiCreateButton(x + half_width, y, 25, 22, gui.enabled and "On" or "Off", false, parent)
    guiSetFont(gui.toggle_btn, "default-small")

    if gui.enabled then
        guiButtonSetColor(gui.toggle_btn, 100, 255, 100)
    else
        guiButtonSetColor(gui.toggle_btn, 255, 100, 100)
    end

    addEventHandler("onClientGUIClick", gui.toggle_btn,
        function ()
            gui.enabled = not gui.enabled

            if gui.enabled then
                guiButtonSetColor(gui.toggle_btn, 100, 255, 100)
                guiSetText(gui.toggle_btn, "On")
                guiSetProperty(self.element, self.propertyName, "True")
            else
                guiButtonSetColor(gui.toggle_btn, 255, 100, 100)
                guiSetText(gui.toggle_btn, "Off")
                guiSetProperty(self.element, self.propertyName, "False")
            end
        end,
    false)

    self.x = x
    self.y = y
    self.parent = parent
    self.gui = gui
end

function Component:_destroyGUI()
    if not self.gui then
        return
    end

    local gui = self.gui
    destroyElement(gui.label)
    destroyElement(gui.toggle_btn)
end

function Component:_moveGUI(x, y, width)
    if not self.gui then
        return
    end

    local gui = self.gui
    local half_width = width / 2
    guiSetPosition(gui.label, x, y + 2, false)
    guiSetPosition(gui.toggle_btn, x + half_width, y, false)

    self.x = x
    self.y = y
end

function Component:_updateGUIVisibility()
    if not self.gui then
        return
    end

    local gui = self.gui
    guiSetVisible(gui.label, self.visible)
    guiSetVisible(gui.toggle_btn, self.visible)
end
