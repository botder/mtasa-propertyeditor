addCommandHandler("propertyeditor",
    function (player)
        triggerClientEvent(player, "client:showPropertyEditor", resourceRoot)
    end,
true, false)
