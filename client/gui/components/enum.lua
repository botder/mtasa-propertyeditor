--
-- Component: Enum
--
local Component = {}
Component.__index = Component

local function createComponent(propertyName, ...)
    local self = setmetatable({}, Component)
    self.propertyName = propertyName
    self.names = {...}
    self.gui = false
    self.visible = true
    self.element = false
    self.x = -1
    self.y = -1
    self.parent = false
    return self
end
createComponentFactory("Enum", createComponent)

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
    local value = guiGetProperty(self.element, self.propertyName)
    guiComboBoxSetSelected(gui.combo, -1)

    for i = 1, #self.names do
        local name = guiComboBoxGetItemText(gui.combo, i - 1)

        if name == value then
            guiComboBoxSetSelected(gui.combo, i - 1)
        end
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

    local value = guiGetProperty(self.element, self.propertyName)
    gui.combo = guiCreateComboBox(x + half_width, y, half_width, 200, "[".. self.propertyName .."]", false, parent)
    
    for i = 1, #self.names do
        local field = self.names[i]
        local item = guiComboBoxAddItem(gui.combo, field)

        if field == value then
            guiComboBoxSetSelected(gui.combo, item)
        end
    end

    guiComboBoxAutoHeight(gui.combo)

    addEventHandler("onClientGUIComboBoxAccepted", gui.combo,
        function ()
            local text = guiComboBoxGetItemText(gui.combo, guiComboBoxGetSelected(gui.combo))

            if text then
                guiSetProperty(self.element, self.propertyName, text)
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
    destroyElement(gui.combo)
end

function Component:_moveGUI(x, y, width)
    if not self.gui then
        return
    end

    local gui = self.gui
    local half_width = width / 2
    guiSetPosition(gui.label, x, y + 2, false)
    guiSetPosition(gui.combo, x + half_width, y, false)
    
    self.x = x
    self.y = y
end

function Component:_updateGUIVisibility()
    if not self.gui then
        return
    end

    local gui = self.gui
    guiSetVisible(gui.label, self.visible)
    guiSetVisible(gui.combo, self.visible)
end
