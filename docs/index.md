Postie is a module acting as an elegant alternative to [RemoteFunctions](https://developer.roblox.com/en-us/api-reference/class/RemoteFunction) that offers a *timeout* parameter when invoking another machine. The main benefit of this is the ability to prevent the server infinitely yielding after invoking the client, which is a major negative to RemoteFunctions.

Postie is really just a wrapper for RemoteEvents and does not use RemoteFunctions under the hood.

### Server to client usage

#### Server
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Postie = require(ReplicatedStorage.Postie)

local function getBallsOnScreen(player)
	local isSuccessful, amountOfBalls = Postie.invokeClient(player, "GetObjectsOnScreen", 5, "Balls")
	if isSuccessful then -- check for timeout
		-- a malicious client can always modify the returned data!
		if typeof(amountOfBalls) == "number" then
			return true, amountOfBalls
		end
	end
	return false
end
```

#### Client
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Postie = require(ReplicatedStorage.Postie)

Postie.setCallback("GetObjectsOnScreen", function(objectType)
	return amountOnScreenByObjectType[objectType]
end)
```

### Client to server usage

#### Server
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Postie = require(ReplicatedStorage.Postie)

Postie.setCallback("GetCoins", function(player)
	return coinsByPlayer[player]
end)
```

#### Client
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Postie = require(ReplicatedStorage.Postie)

local function getCoins()
	return Postie.invokeServer("GetCoins", 5)
end
```
