--[[
	Postie is a module acting as an elegant alternative to RemoteFunctions with a timeout.
	Public release: https://devforum.roblox.com/t/postie-an-elegant-alternative-to-remotefunctions-with-a-timeout/243812
	
	Postie.invokeClient(id: string, player: Instance<Player>, timeout: number, ...sent: any) => isSuccessful: boolean, ...returned: any // yields, server-side
		Invoke player with sent data. Invocation identified by id. Yield until timeout (given in seconds) is reached and return false, or a signal is received back from the client and return true plus the data returned from the client.
	
	Postie.invokeServer(id: string, timeout: number, ...sent: any) => isSuccessful: boolean, ...returned: any // yields, client-side
		Invoke the server with sent data. Invocation identified by id. Yield until timeout (given in seconds) is reached and return false, or a signal is received back from the server and return trure plus the data returned from the server.
	
	Postie.setCallback(id: string, callback?: (...) -> ...returned: any)
		Set the callback that is invoked when an invocation identified by id is sent. Data sent with the invocation are passed to the callback. If on the server, the player who invoked is implicitly received as the first argument.
	
	Postie.getCallback(id: string) => callback?: (...)
		Return the callback corresponding with id.
--]]

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Reliable = require(script.Reliable)
local t = require(script.t)

local sent = script.Sent -- RemoteEvent
local received = script.Received -- RemoteEvent

local isServer = RunService:IsServer()
local callbackById = {}
local listeners = {}


local Postie = {}

function Postie.invokeClient(id, timeout, player, ...)
	assert(isServer, "Postie.invokeClient can only be called from the server")
	local bindable = Instance.new("BindableEvent")
	local isResumed = false
	local pos = #listeners+1
	-- get uuid
	local uuid = HttpService:GenerateGUID(false)
	-- await signal from client
	listeners[pos] = function(playerWhoFired, signalUuid, ...)
		if not (playerWhoFired == player and signalUuid == uuid) then
			return false
		end
		isResumed = true
		table.remove(listeners, pos)
		bindable:Fire(true, ...)
		return true
	end
	-- await timeout
	Reliable.spawn(function()
		Reliable.wait(timeout)
		if isResumed then
			return
		end
		table.remove(listeners, pos)
		bindable:Fire(false)
	end)
	-- send signal
	sent:FireClient(player, id, uuid, ...)
	return bindable.Event:Wait()
end
Postie.invokeClient = t.wrap(Postie.invokeClient, t.tuple(t.string, t.instanceIsA("Player"), t.number))

function Postie.invokeServer(id, timeout, ...)
	assert(not isServer, "Postie.invokeServer can only be called from the client")
	local bindable = Instance.new("BindableEvent")
	local isResumed = false
	local pos = #listeners + 1
	-- get uuid
	local uuid = HttpService:GenerateGUID(false)
	-- await signal from client
	listeners[pos] = function(signalUuid, ...)
		if signalUuid ~= uuid then
			return false
		end
		isResumed = true
		table.remove(listeners, pos)
		bindable:Fire(true, ...)
		return true
	end
	-- await timeout
	Reliable.spawn(function()
		Reliable.wait(timeout)
		if isResumed then
			return
		end
		table.remove(listeners, pos)
		bindable:Fire(false)
	end)
	-- send signal
	sent:FireServer(id, uuid, ...)
	return bindable.Event:Wait()
end
Postie.invokeServer = t.wrap(Postie.invokeServer, t.tuple(t.string, t.number))

function Postie.setCallback(id, callback)
	callbackById[id] = callback
end
Postie.setCallback = t.wrap(Postie.setCallback, t.tuple(t.string, t.optional(t.callback)))

function Postie.getCallback(id)
	return callbackById[id]
end
Postie.getCallback = t.wrap(Postie.getCallback, t.string)


-- handle signals
if isServer then
	-- handle received
	received.OnServerEvent:Connect(function(...)
		for _, listener in ipairs(listeners) do
			if listener(...) then return end
		end
	end)
	-- handle sent
	sent.OnServerEvent:Connect(function(player, id, uuid, ...)
		local callback = callbackById[id]
		if callback == nil then
			received:FireClient(player, uuid)
		else
			received:FireClient(player, uuid, callback(player, ...))
		end
	end)
else
	-- handle received
	received.OnClientEvent:Connect(function(...)
		for _, listener in ipairs(listeners) do
			if listener(...) then return end
		end
	end)
	-- handle sent
	sent.OnClientEvent:Connect(function(id, uuid, ...)
		local callback = callbackById[id]
		if callback == nil then
			received:FireServer(uuid)
		else
			received:FireServer(uuid, callback(...))
		end
	end)
end

return Postie
