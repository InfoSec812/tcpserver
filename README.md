# Simple TCP server

* server provides queue functionality to clients
* one queue per client connection - the queue is created when a client connects and is destroyed when the client disconnects
* the server should be able to handle multiple simultaneous client connections
* communication protocol:
	* line based
	* lines start with the command (in or out), the "in" command is followed by the payload
	* the server returns results one per line
* package the server as an OTP app and use OTP behaviours and supervision structure

## Build & Run


**rebar3** is required to run things. Verified on Erlang/OTP 21

```bash
$ make compile-all
$ make run
```

TCP server should be started on port 5555

## Approach

[ranch](https://github.com/ninenines/ranch) was used to handle TCP server calls and "queue" protocol

## Unit Tests

To run unit test run
```bash
$ make eunit
```

## Known Issues
* App parameters like port or connections timeout are hardcoded. 
* Fix dialyzer warnings

