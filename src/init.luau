--!strict
--!native

-- This implementation of the Janitor uses a stack-based order when operating with a cleanup handlers.

type JanitorObject = Instance | RBXScriptConnection | { [unknown]: unknown }

type Proc = () -> ()

type PromiseLike = {
    cancel: (self: PromiseLike) -> (),
}

export type JanitorImpl<Key, Object = JanitorObject> = {
    __index: JanitorImpl<Key, Object>,
    __tostring: () -> "Janitor",

    add: (
        self: Janitor<Key, Object>,
        object: Object,
        methodName: string,
        key: Key?
    ) -> Janitor<Key, Object>,

    addFn: (
        self: Janitor<Key, Object>,
        fn: Proc,
        key: Key?
    ) -> Janitor<Key, Object>,

    addFunction: (
        self: Janitor<Key, Object>,
        fn: Proc,
        key: Key?
    ) -> Janitor<Key, Object>,

    addSelf: (
        self: Janitor<Key, Object>,
        destroyLike: { destroy: (...unknown) -> ...unknown },
        key: Key?
    ) -> Janitor<Key, Object>,

    addConnection: (
        self: Janitor<Key, Object>,
        connection: RBXScriptConnection,
        key: Key?
    ) -> Janitor<Key, Object>,

    addPromise: (
        self: Janitor<Key, Object>,
        promise: PromiseLike,
        key: Key?
    ) -> Janitor<Key, Object>,

    addInstance: (
        self: Janitor<Key, Object>,
        inst: Instance,
        key: Key?
    ) -> Janitor<Key, Object>,

    addTask: (
        self: Janitor<Key, Object>,
        task: thread,
        key: Key?
    ) -> Janitor<Key, Object>,

    addCoroutine: (
        self: Janitor<Key, Object>,
        co: thread,
        key: Key?
    ) -> Janitor<Key, Object>,

    isKeyAttached: (self: Janitor<Key, Object>, key: Key) -> boolean,
    keysAttached: (self: Janitor<Key, Object>, ...Key) -> boolean,

    clean: (self: Janitor<Key, Object>, ...Key) -> Janitor<Key, Object>,

    remove: (self: Janitor<Key, Object>, ...Key) -> Janitor<Key, Object>,

    cleanup: (self: Janitor<Key, Object>) -> Janitor<Key, Object>,

    destroy: (self: Janitor<Key, Object>) -> (),

    addCleanupRace: (
        self: Janitor<Key, Object>,
        setup: (winRace: Proc) -> Proc,
        onCleanup: Proc,
        key: Key?
    ) -> Janitor<Key, Object>,
}

export type Janitor<Key, Object> = typeof(setmetatable(
    {} :: {},
    {} :: JanitorImpl<Key, Object>
))

export type UnknownJanitor = Janitor<unknown, unknown>

type JanitorItem = Proc | false

-- Each Janitor instance might have it's corresponding JanitorItem stack.
local stackMap = {} :: {
    [UnknownJanitor]: { JanitorItem },
}

local function pushStack(self: UnknownJanitor, fn: Proc): number
    local stack = stackMap[self]
    if not stack then
        stack = {}
        stackMap[self] = stack
    end

    local index = #stack + 1
    stack[index] = fn

    return index
end

-- Basically utilizes the "table.insert" function to increase the runtime speed in cases when
-- there is no need to track the index at which the cleanup function was inserted.
local function pushStackNoReturn(self: UnknownJanitor, func: Proc)
    local stack = stackMap[self]
    if not stack then
        stack = {}
        stackMap[self] = stack
    end

    table.insert(stack, func)
end

-- Indices store a tabla in key-CleanFunction format for each of the Janitor instances.
local indices = {} :: {
    [UnknownJanitor]: {
        [unknown]: Proc,
    },
}

local function setIndiceForFn(self: UnknownJanitor, key: unknown, fn: Proc)
    local this = indices[self]
    if not this then
        this = {}
        indices[self] = this
    end

    this[key] = fn
end

local JanitorImpl = {} :: JanitorImpl<unknown, unknown>
JanitorImpl.__index = JanitorImpl

function JanitorImpl.__tostring()
    return "Janitor"
end

local fnToIndexMap = {} :: { [Proc]: number }

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

    return self
end

--[[
    Janitor units are functions, so every single clean operation will call some function.

    User may want to provide optional "key" argument to clean/remove the CleanFunction regardless of the "cleanup", "destroy" functions.
]]
function JanitorImpl:addFn(func, key)
    if key then
        self:clean(key)

        fnToIndexMap[func] = pushStack(self, func)

        setIndiceForFn(self, key, func)
    else
        pushStackNoReturn(self, func)
    end

    return self
end

-- Alias
JanitorImpl.addFunction = JanitorImpl.addFn

--[[
    Generally works with any table that exposes "destroy" method.

    Shorthand for:
    ```lua
    :add(janitor, "destroy");
    ```
]]
function JanitorImpl:addSelf(janitor, key)
    self:add(janitor, "destroy", key)

    return self
end

--[[
    Shorthand for:
    ```lua
    :add(connection, "Disconnect")
    ```
]]
function JanitorImpl:addConnection(connection, key)
    self:add(connection, "Disconnect", key)

    return self
end

function JanitorImpl:addPromise(promise, key)
    self:add(promise, "cancel", key)

    return self
end

--[[
    Shorthand for:
    ```lua
    :add(instance, "Destroy")
    ```
]]
function JanitorImpl:addInstance(inst, key)
    self:add(inst, "Destroy", key)

    return self
end

--[[
    Shorthand for:
    ```lua
    :addFn(function()
        task.cancel(thread)
    end)
    ```
]]
function JanitorImpl:addTask(_task, key)
    self:addFn(function()
        task.cancel(_task)
    end, key)

    return self
end

--[[
    Shorthand for:
    ```lua
    :addFn(function()
        coroutine.close(thread)
    end)
    ```
]]
function JanitorImpl:addCoroutine(co, key)
    self:addFn(function()
        coroutine.close(co)
    end, key)

    return self
end

function JanitorImpl:isKeyAttached(key)
    local this = indices[self]
    if not this then
        return false
    end

    return this[key] ~= nil
end

function JanitorImpl:keysAttached(...)
    local this = indices[self]
    if not this then
        return false
    end

    for i = 1, select("#", ...) do
        local key = select(i, ...)
        if this[key] == nil then
            return false
        end
    end

    return true
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
            stackMap[self][fnToIndexMap[func]] = false

            fnToIndexMap[func] = nil

            this[key] = nil
        end
    end

    return self
end

function JanitorImpl:remove(key)
    local this = indices[self]
    if this then
        local func = this[key]
        if func then
            stackMap[self][fnToIndexMap[func]] = false

            fnToIndexMap[func] = nil

            this[key] = nil
        end
    end

    return self
end

function JanitorImpl:cleanup()
    local this = stackMap[self]
    if this then
        local func: JanitorItem

        for index = #this, 1, -1 do
            func = this[index]
            if func then
                fnToIndexMap[func] = nil

                func()
            end

            this[index] = nil
        end

        stackMap[self] = nil
    end

    indices[self] = nil

    return self
end

--[[
    Basic usage:
    ```lua
    janitor:addCleanupRace(function(winRace)
        local timeoutThread = task.delay(10, function()
            warn("10 seconds passed, starting the game")
        end)

        return function()
            task.cancel(timeoutThread)
        end
    end, function()
        warn("for whatever reason game starts right now, cleaning up")
    end)
    ```
]]
function JanitorImpl:addCleanupRace(setup, onCleanup, key)
    local innerFn

    local function winRace()
        innerFn = function() end
    end

    local onRaceLoss = setup(winRace)

    innerFn = function()
        onRaceLoss()
        onCleanup()
    end

    self:addFn(function()
        innerFn()
    end, key)

    return self
end

local exports = {}

function JanitorImpl:destroy()
    local this = self :: any

    if exports.is(this) then
        self:cleanup()
    end

    -- Ensure no further method calls can be done
    setmetatable(this, nil)
end

local Janitor = {}

function Janitor.new()
    local self: UnknownJanitor = setmetatable({}, JanitorImpl)

    table.freeze(self)

    return self
end

table.freeze(Janitor)

exports.Janitor = Janitor

function exports.is(value: unknown)
    return type(value) == "table" and getmetatable(value :: any) == JanitorImpl
end

table.freeze(exports)

return exports
