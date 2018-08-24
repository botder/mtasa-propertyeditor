local propertyEditor = createPropertyEditorWindow()

addEvent("client:showPropertyEditor", true)
addEventHandler("client:showPropertyEditor", resourceRoot,
    function ()
        propertyEditor:show()
    end,
false)
