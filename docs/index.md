Postie is a module acting as an elegant alternatives to [RemoteFunctions](https://developer.roblox.com/en-us/api-reference/class/RemoteFunction) that offers a *timeout* parameter when invoking another machine. The main benefit of this is the ability to prevent the server infinitely yielding after invoking the client, which is a major negative to RemoteFunctions.

Postie is really just a wrapper for RemoteEvents and does not RemoteFunctions under the hood.

## Server to client usage

### Server
```
local Postie = require(path.to.Postie)

local function getBallsOnScreen(player)
	local isSuccessful, amountOfBalls = Postie.invokeClient("GetObjectsOnScreen", 5, player, "Balls")
	if isSuccessful then -- check for timeout
		if typeof(amountOfBalls) == "number" then -- the client can always modify the returned data!
			return true, amountOfBalls
		end
	end
	return false
end
```

### Client
```
local Postie = require(path.to.Postie)

Postie.setCallback("GetObjectsOnScreen", function(objectType)
	return amountOnScreenByObjectType[objectType]
end)
```

## Client to server usage

### Server
```
local Postie = require(path.to.Postie)

Postie.setCallback("GetCoins", function(player)
	return coinsByPlayer[player]
end)
```

### Client
```
local Postie = require(path.to.Postie)

local function getCoins()
	return Postie.invokeServer("GetCoins", 5)
end
```
