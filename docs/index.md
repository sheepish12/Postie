Postie is a module that provides a safe alternative to [RemoteFunctions](https://developer.roblox.com/en-us/api-reference/class/RemoteFunction), offering a time-out parameter when invoking another machine. The main benefit of this is that you avoid the issues that come with invoking the client with a RemoteFunction:

* If the client throws an error, the server will throw the error too.
* If the client disconnects while it's being invoked, the InvokeClient call will error.
* If the client never returns a value, the server will hang forever.

Postie solves all three of these problems by replacing one RemoteFunction invocation with two RemoteEvent firings.

### Server to client usage

#### Server
```lua
local Postie = require(the.path.to.Postie)

local function getBallsOnScreen(player)
	-- We request the amount of balls on the client's screen with a time-out of 5 seconds.
	local didRespond, amountOfBalls = Postie.invokeClient(player, "get-objects-on-screen", 5, "balls")
	if didRespond then -- We check for the time-out (or the client has no callback registered).
		-- A malicious client can always modify the returned data!
		if typeof(amountOfBalls) == "number" then
			return true, amountOfBalls
		end
	end
	return false
end
```

#### Client
```lua
local Postie = require(the.path.to.Postie)

Postie.setCallback("get-objects-on-screen", function(objectType)
	return amountOnScreenByObjectType[objectType]
end)
```

### Client to server usage

#### Server
```lua
local Postie = require(the.path.to.Postie)

Postie.setCallback("get-coins", function(player)
	return coinsByPlayer[player]
end)
```

#### Client
```lua
local Postie = require(the.path.to.Postie)

local function getCoins()
	-- We request how many coins we have with a time-out of 5 seconds.
	return Postie.invokeServer("get-coins", 5)
end
```
