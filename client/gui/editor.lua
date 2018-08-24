--
-- Property Editor window
--
local PropertyEditor = {}
PropertyEditor.__index = PropertyEditor

local screenWidth, screenHeight = guiGetScreenSize()

function createPropertyEditorWindow()
    local self = setmetatable({}, PropertyEditor)
    self.width = 600
    self.height = (screenHeight - 20)
    self.visible = false
    self.showingAllProperties = false
    self.currentElement = false
    self.components = {}

    local gui = {}
    self.gui = gui

    local x = (screenWidth - self.width) / 2
    local y = (screenHeight - self.height) / 2
    gui.window = guiCreateWindow(x, y, self.width, self.height, "Property Editor", false)
    guiSetProperty(gui.window, "CloseButtonEnabled", "False")
    guiWindowSetSizable(gui.window, false)
    guiSetVisible(gui.window, false)

    gui.showSelectionButton = guiCreateButton(10, 25, 90, 20, "Return to selection", false, gui.window)
    guiSetFont(gui.showSelectionButton, "default-small")
    addEventHandler("onClientGUIClick", gui.showSelectionButton, bind(self, self._onClickShowSelection), false)

    gui.refreshButton = guiCreateButton(105, 25, 50, 20, "Refresh", false, gui.window)
    guiSetFont(gui.refreshButton, "default-small")
    addEventHandler("onClientGUIClick", gui.refreshButton, bind(self, self._onClickRefresh), false)

    gui.showTreeButton = guiCreateButton(160, 25, 100, 20, "Show element tree", false, gui.window)
    guiSetFont(gui.showTreeButton, "default-small")
    addEventHandler("onClientGUIClick", gui.showTreeButton, bind(self, self._onClickShowTree), false)

    gui.showAllCheckBox = guiCreateCheckBox(265, 25, 100, 20, "Show all properties", self.showingAllProperties, false, gui.window)
    guiSetFont(gui.showAllCheckBox, "default-small")
    addEventHandler("onClientGUIClick", gui.showAllCheckBox, bind(self, self._onClickShowAll), false)

    gui.closeButton = guiCreateButton(self.width - 60, 25, 50, 20, "Close", false, gui.window)
    guiSetFont(gui.closeButton, "default-small")
    addEventHandler("onClientGUIClick", gui.closeButton, bind(self, self._onClickClose), false)

    gui.propertyLabel = guiCreateLabel(10, 50, 100, 20, "Property", false, gui.window)
    guiSetFont(gui.propertyLabel, "default-bold-small")

    gui.valueLabel = guiCreateLabel(10 + (self.width - 50) / 2, 50, 100, 20, "Value", false, gui.window)
    guiSetFont(gui.valueLabel, "default-bold-small")
    
    gui.scrollpane = guiCreateScrollPane(10, 70, self.width - 20, self.height - 80, false, gui.window)
    gui.paddingLabel = guiCreateLabel(0, 0, 0, 0, "", false, gui.scrollpane)

    self.selection = createSelectionWindow(bind(self, self._onSelectionConfirm))
    self.elementTree = createElementTreeWindow(bind(self, self._onElementTreeSelect))

    return self
end

--
-- Public
--
function PropertyEditor:show()
    if not self.visible then
        if isElement(self.currentElement) then
            self:_createComponentsOnDemand()
        else
            self.currentElement = false
            self.selection:show()
            return
        end

        guiSetVisible(self.gui.window, true)
        guiBringToFront(self.gui.window)
        showCursor(true)
        self.visible = true
    end
end

function PropertyEditor:hide()
    if self.visible then
        guiSetVisible(self.gui.window, false)
        showCursor(false)
        self.visible = false
    end
end

function PropertyEditor:destroy()
    self.elementTree:destroy()
    self.selection:destroy()
    destroyElement(self.gui.window)
    setmetatable(self, nil)
    for k in pairs(self) do self[k] = nil end
end

function PropertyEditor:setElement(element)
    assert(isElement(element), debug.traceback())
    assert(getElementType(element):sub(1, 3) == "gui", debug.traceback())

    if self.currentElement == element then
        return
    end

    self.currentElement = element
    self.elementTree:hide()
    self.selection:hide()

    local title
    local text = guiGetText(element)

    if text ~= "" then
        title = ("Property Editor – %s – [%s] %s"):format(guiGetResourceName(element), getElementType(element), text:sub(1, 32))
    else
        title = ("Property Editor – %s – %s"):format(guiGetResourceName(element), getElementType(element))
    end

    guiSetText(self.gui.window, title)

    for propertyName, component in pairs(self.components) do
        component:setElement(element)
    end

    if self.visible then
        self:_createComponentsOnDemand()
    end
end

--
-- Private
--
function PropertyEditor:_createComponentsOnDemand()
    local propertyList = false

    if self.showingAllProperties then
        propertyList = getPropertyList()
    else
        propertyList = getElementTypePropertyList(getElementType(self.currentElement))
    end

    local components = self.components
    local changed = false

    for i = 1, #propertyList do
        local propertyName = propertyList[i]
        local component = components[propertyName]

        if not component then
            local component = createPropertyComponent(propertyName)

            if component then
                components[propertyName] = component
                changed = true
            end
        else
            if not component:isVisible() then
                component:refresh()
                component:show()
                changed = true
            end
        end
    end

    if changed then
        self:_update()
    end
end

function PropertyEditor:_update()
    -- Update all components
    local propertyList = getPropertyList()
    local components = self.components
    local element = self.currentElement
    local scrollpane = self.gui.scrollpane

    local y = 0
    local width = self.width - 50

    for i = 1, #propertyList do
        local propertyName = propertyList[i]
        local component = components[propertyName]

        if component then
            component:setElement(element)
            component:render(0, y, width, scrollpane)

            if component:isVisible() then
                y = y + component:getHeight()
            end
        end
    end

    guiSetPosition(self.gui.paddingLabel, 0, y, false)
end

function PropertyEditor:_onClickShowSelection()
    self:hide()
    self.selection:show()
end

function PropertyEditor:_onClickRefresh()
    for propertyName, component in pairs(self.components) do
        if component:isVisible() then
            component:refresh()
        end
    end
end

function PropertyEditor:_onClickShowTree()
    self:hide()
    self.elementTree:setElement(self.currentElement)
    self.elementTree:show()
end

function PropertyEditor:_onClickShowAll()
    local selected = guiCheckBoxGetSelected(source)
    if self.showingAllProperties == selected then return end
    self.showingAllProperties = selected

    if selected then
        self:_createComponentsOnDemand()
    else
        local propertyList = getElementTypePropertyList(getElementType(self.currentElement))
        
        for i = 1, #propertyList do
            local propertyName = propertyList[i]
            propertyList[propertyName] = true
            propertyList[i] = nil
        end

        local anyComponentHidden = false

        for propertyName, component in pairs(self.components) do
            if not propertyList[propertyName] then
                component:hide()
                anyComponentHidden = true
            end
        end

        if anyComponentHidden then
            self:_update()
        end
    end

    guiScrollPaneSetVerticalScrollPosition(self.gui.scrollpane, 0.0)
end

function PropertyEditor:_onClickClose()
    self:hide()
end

function PropertyEditor:_onSelectionConfirm(element)
    self:setElement(element)
    self:show()
end

function PropertyEditor:_onElementTreeSelect(element)
    self.elementTree:hide()

    if element then
        self:setElement(element)
    end

    self:show()
end
