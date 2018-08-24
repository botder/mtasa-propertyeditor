--
-- Element tree
--
local ElementTree = {}
ElementTree.__index = ElementTree

local screenWidth, screenHeight = guiGetScreenSize()

function createElementTreeWindow(callback)
    local self = setmetatable({}, ElementTree)
    self.callback = callback
    self.width = 600
    self.height = screenHeight - 20
    self.currentElement = false
    self.visible = false

    local gui = {}
    self.gui = gui

    local x = (screenWidth - self.width) / 2
    local y = (screenHeight - self.height) / 2
    gui.window = guiCreateWindow(x, y, self.width, self.height, "GUI element tree", false)
    guiSetProperty(gui.window, "CloseButtonEnabled", "False")
    guiWindowSetSizable(gui.window, false)
    guiSetVisible(gui.window, false)

    gui.gridlist = guiCreateGridList(10, 30, self.width - 20, self.height - 40, false, gui.window)
    guiGridListSetSortingEnabled(gui.gridlist, false)
    addEventHandler("onClientGUIDoubleClick", gui.gridlist, bind(self, self._onSelect), false)

    gui.column = guiGridListAddColumn(gui.gridlist, "Element", 1.0)
    guiGridListSetColumnWidth(gui.gridlist, gui.column, self.width - 50, false)

    gui.close = guiCreateButton((self.width - 50) / 2, 20, 50, 20, "Close", false, gui.window)
    guiSetFont(gui.close, "default-small")
    guiSetProperty(gui.close, "AlwaysOnTop", "True")
    guiSetAlpha(gui.close, 1.0)
    addEventHandler("onClientGUIClick", gui.close, bind(self, self._onClose), false)

    return self
end

local function createChildrenStack(element)
    local children = getElementChildren(element)
    return {
        index    = 0,
        length   = #children,
        children = children,
    }
end

local function getElementGUIRootElement(element)
    assert(isElement(element), debug.traceback())

    while getElementType(element) ~= "guiroot" do
        element = getElementParent(element)
    end

    return element
end

local function getGUIElementTreeList(element)
    local guiRoot = getElementGUIRootElement(element)
    local treeList = {}
    local stack = { createChildrenStack(guiRoot) }
    local level = 1
    local indent = ""

    while level > 0 do
        local s = stack[level]
        local lastChild = ((s.index + 1) == s.length)
        
        if s.index < s.length then
            s.index = s.index + 1
            
            local element = s.children[s.index]
            local elementType = getElementType(element)
            local text = guiGetText(element)
            local prefix = lastChild and "└" or "├"
            
            treeList[#treeList + 1] = {
                text = ("%s%s [%s] %s"):format(indent, prefix, elementType, text),
                element = element,
            }

            if getElementChild(element, 0) then
                level = level + 1
                stack[level] = createChildrenStack(element)

                if lastChild then
                    indent = indent .."   "
                else
                    indent = indent .."│  "
                end
            end
        else
            level = level - 1
            indent = utf8.sub(indent, 1, -4)
        end
    end

    return treeList
end

--
-- Public
--
function ElementTree:destroy()
    destroyElement(self.gui.window)
    setmetatable(self, nil)
    for k in pairs(self) do self[k] = nil end
end

function ElementTree:show()
    if not self.visible then
        showCursor(true)
        guiSetVisible(self.gui.window, true)
        guiBringToFront(self.gui.window)
        self.visible = true
    end
end

function ElementTree:hide()
    if self.visible then
        showCursor(false)
        guiSetVisible(self.gui.window, false)
        self.visible = false
    end
end

function ElementTree:setElement(element)
    assert(isElement(element), debug.traceback())

    if self.currentElement == element then
        return
    end

    local gui = self.gui

    local resourceName = guiGetResourceName(element)
    guiSetText(gui.window, "GUI element tree – ".. resourceName)
    guiGridListClear(gui.gridlist)

    local gridlist = self.gui.gridlist
    local column = self.gui.column
    local row = guiGridListAddRow(gridlist)
    guiGridListSetItemText(gridlist, row, column, resourceName, true, false)

    local resource = getResourceFromName(resourceName)
    if not resource then return end

    local treeList = getGUIElementTreeList(getElementGUIRootElement(element))
    local numItems = #treeList
    local selectedRow = 0

    for i = 1, numItems do
        local data = treeList[i]
        local row = guiGridListAddRow(gridlist)
        guiGridListSetItemText(gridlist, row, column, data.text, false, false)
        guiGridListSetItemData(gridlist, row, column, data.element)

        if data.element == element then
            guiGridListSetSelectedItem(gridlist, row, column)
            guiGridListSetItemColor(gridlist, row, column, 0, 255, 0)
            selectedRow = row
        end
    end

    -- guiGridListSetVerticalScrollPosition is broken:
    -- You have to disable and enable the vertical scrollbar, because otherwise
    -- the scrollbar position won't change everytime you set it
    local verticalPosition = (selectedRow / numItems) * 100
    guiGridListSetScrollBars(gridlist, false, false)
    guiGridListSetScrollBars(gridlist, false, true)
    guiGridListSetVerticalScrollPosition(gridlist, verticalPosition)

    self.currentElement = element
end

--
-- Private
--
function ElementTree:_onSelect()
    local row = guiGridListGetSelectedItem(self.gui.gridlist)
    if not row or row == -1 then return end

    local element = guiGridListGetItemData(self.gui.gridlist, row, self.gui.column)
    if not element then return end

    self.callback(element)
end

function ElementTree:_onClose()
    self.callback(false)
end
