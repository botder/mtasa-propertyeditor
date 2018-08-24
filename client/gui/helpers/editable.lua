--
-- Editable (Button and Edit)
--
local Editable = {}
Editable.__index = Editable

function guiCreateEditable(x, y, width, parent, value, callback)
    local self = setmetatable({}, Editable)

    self.button = guiCreateButton(x, y, 35, 22, "Edit", false, parent)
    guiSetFont(self.button, "default-small")

    self.value = value
    self.editing = false
    self.edit = guiCreateEdit(x + 37, y, width - 37, 22, self.value, false, parent)
    guiSetFont(self.edit, "clear-normal")
    guiSetProperty(self.edit, "ReadOnlyBGColour", "55000000") 
    guiSetProperty(self.edit, "NormalTextColour", "FFFFFFFF") 
    guiSetEnabled(self.edit, false)
    guiEditSetReadOnly(self.edit, true)

    addEventHandler("onClientGUIClick", self.button,
        function ()
            self.editing = not self.editing

            if self.editing then
                guiSetEnabled(self.edit, true)
                guiEditSetReadOnly(self.edit, false)
                guiSetProperty(self.edit, "NormalTextColour", "FF000000") 
                guiSetText(self.button, "Cancel")
                guiSetInputMode("no_binds")
            else
                guiSetEnabled(self.edit, false)
                guiEditSetReadOnly(self.edit, true)
                guiSetProperty(self.edit, "NormalTextColour", "FFFFFFFF") 
                guiSetText(self.button, "Edit")
                guiSetText(self.edit, self.value)
                guiSetInputMode("allow_binds")

                -- Don't show the selection in read-only presentation
                guiSetProperty(self.edit, "SelectionLength", 0) 
            end
        end,
    false)

    addEventHandler("onClientGUIAccepted", self.edit,
        function ()
            if not self.editing then return end
            self.editing = false

            guiSetEnabled(self.edit, false)
            guiEditSetReadOnly(self.edit, true)
            guiSetProperty(self.edit, "NormalTextColour", "FFFFFFFF") 
            guiSetProperty(self.edit, "CaratIndex", 0)

            local content = guiGetText(source)
            if callback(content) then
                self.value = content
            else
                guiSetText(source, self.value)
            end

            guiSetText(self.button, "Edit")
            guiSetInputMode("allow_binds")
        end,
    false)

    return self
end

--
-- Public
--
function Editable:destroy()
    destroyElement(self.button)
    destroyElement(self.edit)

    setmetatable(self, nil)
    for k in pairs(self) do self[k] = nil end
end

function Editable:setVisible(visible)
    guiSetVisible(self.button, visible)
    guiSetVisible(self.edit, visible)
end

function Editable:setValue(value)
    guiSetText(self.edit, value)
    self.value = value
end

function Editable:move(x, y)
    guiSetPosition(self.button, x, y, false)
    guiSetPosition(self.edit, x + 37, y - 2, false)
end
