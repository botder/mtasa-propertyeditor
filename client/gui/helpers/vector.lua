--
-- Vector
--
local Vector = {}
Vector.__index = Vector

local function getXYFromVector2(value)
    return gettok(value, 1, ","), gettok(value, 2, ",")
end

function guiCreateVector2(x, y, width, parent, value, callback)
    local self = setmetatable({}, Vector)
    self.callback = callback

    self.value_x, self.value_y = getXYFromVector2(value)

    self.edit_width = (width / 2) - 3
    self.edit_x = guiCreateEdit(x,                        y, self.edit_width, 22, self.value_x or "0.0", false, parent)
    self.edit_y = guiCreateEdit(x + self.edit_width + 6,  y, self.edit_width, 22, self.value_y or "0.0", false, parent)

    addEventHandler("onClientGUIAccepted", self.edit_x, bind(self, self._editX), false)
    addEventHandler("onClientGUIAccepted", self.edit_y, bind(self, self._editY), false)

    self.comma = guiCreateLabel(x + self.edit_width + 1, y + 5, 20, 20, ",", false, parent)
    guiSetFont(self.comma, "clear-normal")

    return self
end

--
-- Public
--
function Vector:destroy()
    destroyElement(self.edit_x)
    destroyElement(self.edit_y)
    destroyElement(self.comma)

    setmetatable(self, nil)
    for k in pairs(self) do self[k] = nil end
end

function Vector:setVisible(visible)
    guiSetVisible(self.edit_x, visible)
    guiSetVisible(self.edit_y, visible)
    guiSetVisible(self.comma, visible)
end

function Vector:setValue(value)
    self.value_x, self.value_y = getXYFromVector2(value)
    guiSetText(self.edit_x, self.value_x or "0.0")
    guiSetText(self.edit_y, self.value_y or "0.0")
end

function Vector:move(x, y)
    guiSetPosition(self.edit_x, x, y, false)
    guiSetPosition(self.edit_y, x + self.edit_width + 6, y, false)
    guiSetPosition(self.comma, x + self.edit_width + 1, y + 5, false)
end

--
-- Private
--
function Vector:_editX()
    self.value_x = guiGetText(source)
    self.callback(self.value_x, self.value_y)
end

function Vector:_editY()
    self.value_y = guiGetText(source)
    self.callback(self.value_x, self.value_y)
end
