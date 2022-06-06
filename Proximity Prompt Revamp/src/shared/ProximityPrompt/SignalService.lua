--// Connection class core
local Connection = {}
Connection.__index = Connection

--// Util
local insertTable = table.insert
local async = task.spawn

--// Consts
local WEAK_KEYS_METATABLE = { __mode = 'k' }

--// Types
export type CustomConnection = typeof(setmetatable({} :: { _callback: (...any?) -> () }, Connection))

--// Connection constructor
setmetatable(Connection, {
	__call = function(class, ...)
		local self = setmetatable({}, class)
		self:constructor(...)
		return self
	end
})

function Connection:constructor(_callback: (...any?) -> ()): CustomConnection
	self._callback = _callback
end

--// Functions
function Connection.Is(t: any): boolean
	return typeof(t) == 'table' and getmetatable(t) == Connection
end

--// Methods
function Connection:Destroy()
	self._callback = nil
	setmetatable(self, nil)
end

--// Metamethods
function Connection:__tostring()
	return ([[
 
    Connection: {
            Callback = %s
    }
        
    ]]):format(tostring(self._callback))
end

-------------------------------------------------------------------------------------------------------------

--// Signal class core
local Signal = {}
Signal.__index = Signal

--// Types
export type CustomSignal = typeof(setmetatable({} :: { _threads: {[number]: thread }, _connections: { [number]: any }}, Signal))

--// Signal constructor
setmetatable(Signal, {
	__call = function(class)
		local self = setmetatable({}, class)
		self:constructor()
		return self
	end
})

function Signal:constructor(): CustomSignal
	self._threads = setmetatable({}, WEAK_KEYS_METATABLE)
	self._connections = setmetatable({}, WEAK_KEYS_METATABLE)
end

--// Functions
function Signal.Is(t: any): boolean
	return typeof(t) == 'table' and getmetatable(t) == Signal
end

--// Methods
function Signal:Connect(_callback: (...any?) -> ()): CustomConnection
	local newConnection = Connection(_callback)
	insertTable(self._connections, newConnection)

	return newConnection
end

function Signal:Fire(...: any?): ()
	for _, connection in ipairs(self._connections) do
		if connection then          
			async(connection._callback, ...)
		end
	end

	for _, threadToResume in ipairs(self._threads) do
		if threadToResume then          
			async(threadToResume, ...)
		end
	end
end

function Signal:Wait()
	local currentThread = coroutine.running()
	insertTable(self._threads, currentThread)

	return coroutine.yield()
end

function Signal:Disconnect()
	table.clear(self._connections)
end

function Signal:__tostring()
	return 'Signal'
end

--// End
return Signal