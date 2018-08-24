--
-- Component: Vector 2x4
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
    self.value_a = "{0,0}"
    self.value_b = "{0,0}"
    self.value_c = "{0,0}"
    self.value_d = "{0,0}"
    return self
end
createComponentFactory("Vector2x4", createComponent)

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

    -- {{1,2},{1,2},{1,2},{1,2}} => {1,2},{1,2},{1,2},{1,2} => {1,2}|{1,2}|{1,2}|{1,2}
    --                                                           a     b     c     d
    local value = guiGetProperty(self.element, self.propertyName)
    value = split(value:sub(2, -2):gsub("(%b{}),", "%1|"), "|")
    self.value_a = value[1]
    self.value_b = value[2]
    self.value_c = value[3]
    self.value_d = value[4]
    
    gui.vectorA:setValue(self.value_a:sub(2, -2))
    gui.vectorB:setValue(self.value_b:sub(2, -2))
    gui.vectorC:setValue(self.value_c:sub(2, -2))
    gui.vectorD:setValue(self.value_d:sub(2, -2))
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
    return self.gui and 100 or 0
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

    gui.label = guiCreateLabel(x, y + 37, half_width, 20, self.propertyName, false, parent)
    guiSetFont(gui.label, "clear-normal")

    -- {{1,2},{1,2},{1,2},{1,2}} => {1,2},{1,2},{1,2},{1,2} => {1,2}|{1,2}|{1,2}|{1,2}
    --                                                           a     b     c     d
    local value = guiGetProperty(self.element, self.propertyName)
    value = split(value:sub(2, -2):gsub("(%b{}),", "%1|"), "|")
    self.value_a = value[1]
    self.value_b = value[2]
    self.value_c = value[3]
    self.value_d = value[4]

    gui.labelA = guiCreateLabel(x + half_width, y + 3, 15, 20, "A:", false, parent)
    gui.vectorA = guiCreateVector2(x + half_width + 17, y, half_width - 17, parent, self.value_a:sub(2, -2),
        function (x, y)
            self.value_a = ("{%s,%s}"):format(x, y)
            guiSetProperty(self.element, name, ("{%s,%s,%s,%s}"):format(self.value_a, self.value_b, self.value_c, self.value_d))
        end
    )

    gui.labelB = guiCreateLabel(x + half_width, y + 25, 15, 20, "B:", false, parent)
    gui.vectorB = guiCreateVector2(x + half_width + 17, y + 22, half_width - 17, parent, self.value_b:sub(2, -2),
        function (x, y)
            self.value_b = ("{%s,%s}"):format(x, y)
            guiSetProperty(self.element, name, ("{%s,%s,%s,%s}"):format(self.value_a, self.value_b, self.value_c, self.value_d))
        end
    )

    gui.labelC = guiCreateLabel(x + half_width, y + 47, 15, 20, "C:", false, parent)
    gui.vectorC = guiCreateVector2(x + half_width + 17, y + 44, half_width - 17, parent, self.value_c:sub(2, -2),
        function (x, y)
            self.value_c = ("{%s,%s}"):format(x, y)
            guiSetProperty(self.element, name, ("{%s,%s,%s,%s}"):format(self.value_a, self.value_b, self.value_c, self.value_d))
        end
    )

    gui.labelD = guiCreateLabel(x + half_width, y + 69, 15, 20, "D:", false, parent)
    gui.vectorD = guiCreateVector2(x + half_width + 17, y + 66, half_width - 17, parent, self.value_d:sub(2, -2),
        function (x, y)
            self.value_d = ("{%s,%s}"):format(x, y)
            guiSetProperty(self.element, name, ("{%s,%s,%s,%s}"):format(self.value_a, self.value_b, self.value_c, self.value_d))
        end
    )

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
    destroyElement(gui.labelA)
    destroyElement(gui.labelB)
    destroyElement(gui.labelC)
    destroyElement(gui.labelD)
    gui.vectorA:destroy()
    gui.vectorB:destroy()
    gui.vectorC:destroy()
    gui.vectorD:destroy()
end

function Component:_moveGUI(x, y, width)
    if not self.gui then
        return
    end

    local gui = self.gui
    local half_width = width / 2
    guiSetPosition(gui.label, x, y + 37, false)
    guiSetPosition(gui.labelA, x + half_width, y + 3, false)
    guiSetPosition(gui.labelB, x + half_width, y + 25, false)
    guiSetPosition(gui.labelC, x + half_width, y + 47, false)
    guiSetPosition(gui.labelD, x + half_width, y + 69, false)
    gui.vectorA:move(x + half_width + 17, y, false)
    gui.vectorB:move(x + half_width + 17, y + 22, false)
    gui.vectorC:move(x + half_width + 17, y + 44, false)
    gui.vectorD:move(x + half_width + 17, y + 66, false)
    
    self.x = x
    self.y = y
end

function Component:_updateGUIVisibility()
    if not self.gui then
        return
    end

    local gui = self.gui
    guiSetVisible(gui.label, self.visible)
    guiSetVisible(gui.labelA, self.visible)
    guiSetVisible(gui.labelB, self.visible)
    guiSetVisible(gui.labelC, self.visible)
    guiSetVisible(gui.labelD, self.visible)
    gui.vectorA:setVisible(self.visible)
    gui.vectorB:setVisible(self.visible)
    gui.vectorC:setVisible(self.visible)
    gui.vectorD:setVisible(self.visible)
end
