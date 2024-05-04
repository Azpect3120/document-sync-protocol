# Document Sync Protocol

View the specification [here](https://github.com/Azpect3120/document-sync-protocol/blob/master/specification.md).


# Dev Notes

### Refactor!

I want the `connect to server` event to actually be an event. Which means I need
the client to create a TCP connection to the server before actually connecting...?
**BASICALLY** I want the client to connect (TCP) and then "connect" by emitting the 
event to the server. The server can then handle the event and do whatever it needs
to do. For example, send a message to all the clients notifying them that a new client
has connected.


## Future Features

I want an event that the client sends that will request a response which the server returns
the number of clients connected and their identifiers.
