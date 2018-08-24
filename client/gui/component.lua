--
-- Component
--
local factories = {}
local properties = {}

function createComponentFactory(name, factoryFunction)
    assert(factories[name] == nil)
    assert(type(factoryFunction) == "function")
    factories[name] = factoryFunction
end

function setPropertyComponent(name, component, arguments)
    assert(properties[name] == nil)
    assert(type(component) == "string")

    properties[name] = {
        name        = name,
        component   = component,
        arguments   = arguments,
    }
end

function createPropertyComponent(name)
    local property = properties[name]
    
    if not property then
        return false
    end

    local factory = factories[property.component]

    if not factory then
        return false
    end

    if property.arguments then
        return factory(name, unpack(property.arguments))
    else
        return factory(name)
    end
end
