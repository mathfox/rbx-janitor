--!strict
--!native

-- This implementation of the Janitor uses a stack-based order when operating with a cleanup handlers.

type JanitorObject = Instance | RBXScriptConnection | { [unknown]: unknown }

type Proc = () -> ()

export type JanitorImpl<Key, Object = JanitorObject> = {
    __index: JanitorImpl<Key, Object>,
    __tostring: () -> "Janitor",

    add: (
        self: Janitor<Key, Object>,
        object: Object,
        methodName: string,
        key: Key?
    ) -> (),

    addFn: (self: Janitor<Key, Object>, func: Proc, key: Key?) -> (),
    addSelf: (
        self: Janitor<Key, Object>,
        janitor: unknown,
        key: Key?
    ) -> (),
    addConnection: (
        self: Janitor<Key, Object>,
        connection: RBXScriptConnection,
        key: Key?
    ) -> (),
    addInstance: (
        self: Janitor<Key, Object>,
        inst: Instance,
        key: Key?
    ) -> (),

    isKeyAttached: (self: Janitor<Key, Object>, key: Key) -> boolean,
    clean: (self: Janitor<Key, Object>, key: Key) -> (),

    remove: (self: Janitor<Key, Object>, key: Key) -> (),

    cleanup: (self: Janitor<Key, Object>) -> (),

    destroy: (self: Janitor<Key, Object>) -> (),

    addRace: (
        self: Janitor<Key, Object>,
        setup: (winRace: Proc) -> Proc,
        onCleanup: Proc,
        key: Key?
    ) -> Key,
}

export type Janitor<Key, Object> = typeof(setmetatable(
    {} :: {},
    {} :: JanitorImpl<Key, Object>
))

export type UnknownJanitor = Janitor<unknown, unknown>

type JanitorItem = Proc | false

local stack = {} :: {
    [UnknownJanitor]: { JanitorItem },
}

local function pushStack(self: UnknownJanitor, func: Proc): number
    local this = stack[self]
    if not this then
        this = {}
        stack[self] = this
    end

    local index = #this + 1
    this[index] = func

    return index
end

-- Basically utilizes the "table.insert" function to increase the speed in cases when
-- there is no need to know about the index at which the cleanup function was insterted.
local function pushStackNoReturn(self: UnknownJanitor, func: Proc)
    local this = stack[self]
    if not this then
        this = {}
        stack[self] = this
    end

    table.insert(this, func)
end

local indices = {} :: {
    [UnknownJanitor]: {
        [unknown]: Proc,
    },
}

local function pushIndice(self: UnknownJanitor, key: unknown, func: Proc)
    local this = indices[self]
    if not this then
        this = {}
        indices[self] = this
    end

    this[key] = func
end

local JanitorImpl = {} :: JanitorImpl<unknown, unknown>
JanitorImpl.__index = JanitorImpl

function JanitorImpl.__tostring()
    return "Janitor"
end

local funcToIndexMap: { [Proc]: number } = {}

--[[
    Supposed to be used with Instances/tables.

    Basic usage:

    local janitor = Janitor.new()

    janitor:add(connection, "Disconnect")
    -- The equivalent is:
    janitor:addFunction(function()
        connection:Disconnect()
    end)

    janitor:add(instance, "Destroy")
    -- The equivalent is:
    janitor:addFunction(function()
        instance:Destroy()
    end)
]]

function JanitorImpl:add(object, methodName, key)
    self:addFn(function()
        local indexableByKey = object :: any

        indexableByKey[methodName](object)
    end, key)
end

function JanitorImpl:addFn(func, key)
    if key then
        self:clean(key)

        funcToIndexMap[func] = pushStack(self, func)

        pushIndice(self, key, func)
    else
        pushStackNoReturn(self, func)
    end
end

-- Shorthand for :add(janitor, "destroy")
function JanitorImpl:addSelf(janitor, key)
    self:add(janitor, "destroy", key)
end

-- Shorthand for :add(connection, "Disconnect")
function JanitorImpl:addConnection(connection, key)
    self:add(connection, "Disconnect", key)
end

-- Shorthand for :add(instance, "Destroy")
function JanitorImpl:addInstance(inst, key)
    self:add(inst, "Destroy", key)
end

function JanitorImpl:isKeyAttached(key)
    local this = indices[self]
    if not this then
        return false
    end

    local func = this[key]
    return func ~= nil
end

-- Cleans a specific task, also replaces the JanitorItem in-place in a stack from a function to a value 'false'.
function JanitorImpl:clean(key)
    local this = indices[self]
    if this then
        local func = this[key]
        if func then
            func()

            -- Basically marking down as the one that should be ignored in the future
            -- so we preserve the same ordering without expensive remove operations;
            stack[self][funcToIndexMap[func]] = false

            funcToIndexMap[func] = nil

            this[key] = nil
        end
    end
end

function JanitorImpl:remove(key)
    local this = indices[self]
    if this then
        local func = this[key]
        if func then
            stack[self][funcToIndexMap[func]] = false

            funcToIndexMap[func] = nil

            this[key] = nil
        end
    end
end

function JanitorImpl:cleanup()
    local this = stack[self]
    if this then
        local func: JanitorItem

        for index = #this, 1, -1 do
            func = this[index]
            if func then
                funcToIndexMap[func] = nil

                func()
            end

            this[index] = nil
        end

        stack[self] = nil
    end

    indices[self] = nil
end

function JanitorImpl:addRace(setup, onCleanup, key)
    if not key then
        key = {}
    end

    local isRaceEnded = false

    local function winRace()
        if isRaceEnded then
            error(
                '\n\tUnable to win the race as the "clean" function has already been called.'
                    .. '\n\tDid you forget to disconnect the race handler by using "winRace" function?',
                2
            )
        end

        isRaceEnded = true
        self:remove(key)
    end

    local onRaceLoss = setup(winRace)

    self:addFn(function()
        isRaceEnded = true
        onRaceLoss()
        onCleanup()
    end, key)

    return key
end

function JanitorImpl:destroy()
    self:cleanup()

    -- Ensure no further method calls can be done
    setmetatable((self :: any) :: {}, nil)
end

local Janitor = {}

function Janitor.is(value)
    return type(value) == "table" and getmetatable(value) == JanitorImpl
end

function Janitor.new()
    local self: UnknownJanitor = setmetatable({}, JanitorImpl)

    return self
end

return {
    Janitor = Janitor,
}
