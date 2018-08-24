--
-- Component: Colors
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
    self.color = {}
    return self
end
createComponentFactory("Color4", createComponent)

local function getARGBFromString(a, r, g, b)
    return ("%02X%02X%02X%02X"):format(a, r, g, b)
end

local function getColorsString(tl, tr, bl, br)
    tr = tr or tl
    bl = bl or tl
    br = br or tl
    return ("tl:%s tr:%s bl:%s br:%s"):format(tl, tr, bl, br)
end

local function getColorsFromString(colorsString)
    return colorsString:match("tl:(%x+) tr:(%x+) bl:(%x+) br:(%x+)")
end

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
    local tl, tr, bl, br = getColorsFromString(value)

    self.color.tl = tl or "FFFFFFFF"
    self.color.tr = tr or "FFFFFFFF"
    self.color.bl = bl or "FFFFFFFF"
    self.color.br = br or "FFFFFFFF"
    local colorsString = getColorsString(self.color.tl, self.color.tr, self.color.bl, self.color.br)

    guiSetProperty(gui.background, "ImageColours", colorsString)
    
    if self.color.tl ~= self.color.tr or self.color.tl ~= self.color.bl or self.color.tl ~= self.color.br then
        if gui.selected == "all" then
            gui.selected = "tl"
            guiRadioButtonSetSelected(gui.radio.tl, true)
        end

        local color = self.color[gui.selected]
        gui.colorpicker:setColor(color)
    else
        guiRadioButtonSetSelected(gui.radio.all, true)
        gui.colorpicker:setColor(self.color.tl)
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
    return self.gui and 105 or 0
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
    local tl, tr, bl, br = getColorsFromString(value)

    self.color.tl = tl or "FFFFFFFF"
    self.color.tr = tr or "FFFFFFFF"
    self.color.bl = bl or "FFFFFFFF"
    self.color.br = br or "FFFFFFFF"
    local colorsString = getColorsString(self.color.tl, self.color.tr, self.color.bl, self.color.br)

    gui.frame = guiCreateGridList(x, y + 20, 150, 75, false, parent)
    addEventHandler("onClientGUIClick", gui.frame, bind(self, self._clickFrame))
    
    gui.background = guiCreateStaticImage(5, 5, 140, 65, "assets/dot.png", false, gui.frame)
    guiSetProperty(gui.background, "ImageColours", colorsString)
    guiSetEnabled(gui.background, false)

    gui.radio = {}
    gui.radio.tl = guiCreateRadioButton(  2,  0, 20, 20, "", false, gui.frame)
    gui.radio.bl = guiCreateRadioButton(  2, 56, 20, 20, "", false, gui.frame)
    gui.radio.tr = guiCreateRadioButton(133,  0, 20, 20, "", false, gui.frame)
    gui.radio.br = guiCreateRadioButton(133, 56, 20, 20, "", false, gui.frame)
    gui.radio.all = guiCreateRadioButton(65, 28, 20, 20, "", false, gui.frame)

    gui.selected = "all"

    if self.color.tl ~= self.color.tr or self.color.tl ~= self.color.bl or self.color.tl ~= self.color.br then
        gui.selected = "tl"
        guiRadioButtonSetSelected(gui.radio.tl, true)
    else
        guiRadioButtonSetSelected(gui.radio.all, true)
    end

    gui.colorpicker = guiCreateColorPicker(x + half_width, y, half_width, parent, self.color.tl,
        function (color)
            if guiRadioButtonGetSelected(gui.radio.all) then
                self.color.tl = color
                self.color.bl = color
                self.color.tr = color
                self.color.br = color
            elseif guiRadioButtonGetSelected(gui.radio.tl) then
                self.color.tl = color
            elseif guiRadioButtonGetSelected(gui.radio.bl) then
                self.color.bl = color
            elseif guiRadioButtonGetSelected(gui.radio.tr) then
                self.color.tr = color
            elseif guiRadioButtonGetSelected(gui.radio.br) then
                self.color.br = color
            end

            local colorsString = getColorsString(self.color.tl, self.color.tr, self.color.bl, self.color.br)
            guiSetProperty(gui.background, "ImageColours", colorsString)
            guiSetProperty(self.element, self.propertyName, colorsString)
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
    destroyElement(gui.frame)
    gui.colorpicker:destroy()
end

function Component:_moveGUI(x, y, width)
    if not self.gui then
        return
    end

    local gui = self.gui
    local half_width = width / 2
    guiSetPosition(gui.label, x, y + 2, false)
    guiSetPosition(gui.frame, x, y + 20, false)
    gui.colorpicker:move(x + half_width, y)
    
    self.x = x
    self.y = y
end

function Component:_updateGUIVisibility()
    if not self.gui then
        return
    end

    local gui = self.gui
    guiSetVisible(gui.label, self.visible)
    guiSetVisible(gui.frame, self.visible)
    gui.colorpicker:setVisible(self.visible)
end

function Component:_clickFrame()
    local gui = self.gui

    if source == gui.frame then
        return
    end

    if guiRadioButtonGetSelected(gui.radio.all) then
        if gui.selected == "all" then return end
        local color = self.color[gui.selected]
        self.color.tl = color
        self.color.tr = color
        self.color.bl = color
        self.color.br = color
        gui.colorpicker:setColor(color)
        gui.selected = "all"
    elseif guiRadioButtonGetSelected(gui.radio.tl) then
        if gui.selected == "tl" then return end
        gui.colorpicker:setColor(self.color.tl)
        gui.selected = "tl"
    elseif guiRadioButtonGetSelected(gui.radio.tr) then
        if gui.selected == "tr" then return end
        gui.colorpicker:setColor(self.color.tr)
        gui.selected = "tr"
    elseif guiRadioButtonGetSelected(gui.radio.bl) then
        if gui.selected == "bl" then return end
        gui.colorpicker:setColor(self.color.bl)
        gui.selected = "bl"
    elseif guiRadioButtonGetSelected(gui.radio.br) then
        if gui.selected == "br" then return end
        gui.colorpicker:setColor(self.color.br)
        gui.selected = "br"
    end
end
