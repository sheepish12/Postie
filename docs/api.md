### Postie.invokeClient
```
Postie.invokeClient(
	player: Player,
	id: string,
	timeOut: number,
	...data: any
) => didRespond: boolean, ...response: any
```

Invoke player with sent data. Invocation identified by *id*. Yield until *timeOut* (given in seconds) is reached and return `false`, or a response is received back from the client and return `true` plus the data returned from the client. If the invocation reaches the client, but the client doesn't have a corresponding callback, return before *timeOut* regardless but return `false`.
!!! info
	This function yields.

!!! warning
	This function will error if it is called from the client.

### Postie.invokeServer
```
Postie.invokeServer(
	id: string,
	timeOut: number,
	...data: any
) => didRespond: boolean, ...response: any
```

Invoke the server with sent data. Invocation identified by *id*. Yield until *timeOut* (given in seconds) is reached and return `false`, or a response is received back from the server and return `true` plus the data returned from the server. If the invocation reaches the server, but the server doesn't have a corresponding callback, return before *timeOut* regardless but return `false`.

!!! info
	This function yields.

!!! warning
	This function will error if it is called from the server.

### Postie.setCallback
```
Postie.setCallback(
	id: string,
	callback?: (...data: any) -> ...response: any
)
```

Set the callback that is invoked when an invocation identified by *id* is sent. Data sent with the invocation are passed to the callback. If on the server, the player who invoked is implicitly received as the first argument. If `nil` is passed instead of a function, the current callback will just be removed.

### Postie.getCallback
```
Postie.getCallback(
	id: string
) => callback?: (...data: any) -> ...response: any
```

Return the callback corresponding with *id*.
