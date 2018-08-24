function guiButtonSetColor(button, r, g, b, a)
    a = a or 255
    return guiSetProperty(button, "NormalTextColour", ("%02x%02x%02x%02x"):format(a, r, g, b))
end

function guiComboBoxAutoHeight(comboBox)
    -- Add a pseudo item to figure out the amount of items
    local itemID = guiComboBoxAddItem(comboBox, "")
    guiComboBoxRemoveItem(comboBox, itemID)

    local width = guiGetSize(comboBox, false)
    return guiSetSize(comboBox, width, itemID * 14 + 40, false)
end

function guiGetResourceName(element)
    while true do
        element = getElementParent(element)

        if not element or element == root then
            break
        end
        
        if getElementType(element) == "resource" then
            return getElementID(element)
        end
    end

    return false
end

function guiGetRelativePosition(element, screenX, screenY)
    while element ~= guiRoot do
        local x, y = guiGetPosition(element, false)
        screenX = screenX - x
        screenY = screenY - y
        element = getElementParent(element)
    end

    return screenX, screenY
end

function hasElementAsParent(element, parent)
    assert(isElement(element), debug.traceback())
    assert(isElement(parent), debug.traceback())

    if parent == root then
        return true
    end

    while true do
        if element == parent then
            return true
        end

        if element == root then
            break
        end

        element = getElementParent(element)
    end

    return false
end

function bind(self, func)
    return function (...) func(self, ...) end
end
