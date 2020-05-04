### Postie.invokeClient
```
Postie.invokeClient(
	player: Instance<Player>,
	id: string,
	timeout: number,
	...sent: any
) => isSuccessful: boolean, ...returned: any
```

Invoke player with sent data. Invocation identified by *id*. Yield until *timeout* (given in seconds) is reached and return false, or a signal is received back from the client and return true plus the data returned from the client.

!!! warning
	This function will throw if it is called from the client.

!!! info
	This function yields.

### Postie.invokeServer
```
Postie.invokeServer(
	id: string,
	timeout: number,
	...sent: any
) => isSuccessful: boolean, ...returned: any
```

Invoke the server with sent data. Invocation identified by *id*. Yield until *timeout* (given in seconds) is reached and return false, or a signal is received back from the server and return true plus the data returned from the server.

!!! warning
	This function will throw if it is called from the server.

!!! info
	This function yields.

### Postie.setCallback
```
Postie.setCallback(
	id: string,
	callback?: (...) -> ...returned: any
)
```

Set the callback that is invoked when an invocation identified by *id* is received. Data sent with the invocation are passed to the callback. If server-side, the player who invoked is implicitly received as the first argument.

### Postie.getCallback
```
Postie.getCallback(
	id: string
) => callback?: (...)
```

Return the callback corresponding with *id*.
