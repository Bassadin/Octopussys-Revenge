-- LOO: Lua Object Oriented
-- Author: Michael Carius <michael.a.carius@gmail.com>

local loo = {}

-- Python-style classes
-- (sorta)
function loo.class()
    local classObject = {}

    -- Properties support
    function classObject:__index(key)
        if classObject.__properties and classObject.__properties[key] then
            return classObject.__properties[key].get(self)
        else
            -- Emulate getmetatable(self).__index = classObject
            return classObject[key]
        end
    end
    function classObject:__newindex(key, value)
        if classObject.__properties and classObject.__properties[key] then
            classObject.__properties[key].set(self, value)
        else
            -- Normal setting behavior
            rawset(self, key, value)
        end
    end

    -- Instantiate the class (and optionally call a constructor) by calling it
    local classMetatable = {
        __call = function(class, ...)
            local instance = setmetatable({}, classObject)
            if classObject.initialize then
                instance:initialize(...)
            end
            return instance
        end,
    }

    return setmetatable(classObject, classMetatable)
end

return loo
