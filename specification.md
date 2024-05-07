# Specification 

### Version `0.0.1`

<br>

**What is the document sync protocol?**

    The document sync protocol allows two or more users to edit the same file at the same time. 

**How does it work?** 

    TCP server will be started by the server user and the clients will establish a TCP connection to the server.
    When the connection is successful, the capabilities will be sent from the server and the client will implement the functionality to allow syncing between the server and connected clients.

<br>

## <a id="TableOfContents">Table Of Contents</a>
- [Events and Notifications](#EventsAndNotifications)
  - [Start Server](#StartServer)
  - [Stop Server](#StopServer)
  - [Connect to Server](#ConnectToServer)
  - [Disconnect from Server](#DisconnectFromServer)
  - [Sync Document](#SyncDocument)
  - [Update Document](#UpdateDocument)
  - [Open Document](#OpenDocument)
  - [Close Document](#CloseDocument)
  - [List Documents](#ListDocuments)
- [Server & Client Shared Types](#Server&ClientSharedTypes)
  - [Server Capabilities](#ServerCapabilities)


<br>

## <a id="EventsAndNotifications">Events and Notifications</a>

### <a id="StartServer">Start Server</a>

Ran by the user who wishes to start a server. Senders file content will be updated by the connected users, assuming the server implements such capabilities.

NOTE: `Event` is not really the right word to describe what this action. `Function` may be a better word to describe how this works. The server must first run a function that implements the following interface which will start up the server, then events can begin.

#### <a id="StartServer">Event</a>

```typescript
interface StartServerEvent {
    /**
     *  Name of the event being emitted.
     *  Event properties are unique and found in all events.
     */
    event: string = "server/start";

    /**
     *  Address to start the server on.
     *  Port should be provided as well.
     *  If not provided, the server will start on the default port: 3270
     */
    host: string;

    /**
     *  Define the capabilities the server will implement.
     *  If empty, the server will not implement any capabilities.
     *  If not provided, the server will fail to start. If this 
     *  value is null, the server will implement the default
     *  capabilities, which can be found in the type definition.
     */
    capabilities: ServerCapabilities;

    /**
     *  Max number of clients that can connect to the server.
     *  Can be upgraded later to allow for more connections.
     *  If not provided, the server will allow the default of
     *  10 connections.
     */
    maxConnections: integer = 10;

    /**
     *  Password required to connect to the server.
     *  If not value is null (""), the server will not require
     *  a password.
     */
    password: string;
}
```

#### <a id="StartServerResponse">Response</a>

This response should be returned by the `function` someway or another.

```typescript
interface StartServerResponse {
    /**
     *  Address the server is running on.
     *  Port should be provided as well.
     */
    host: string;

    /**
     *  Status of the server.
     */
    success: boolean;

    /**
     *  Error returned if success is false.
     *  If server is started successfully, this will be null.
     */
    error: string | null;
}
```

<br>

### <a id="StopServer">Stop Server</a>

Ran by the user who wishes to stop their running server. The server will no longer accept connections and the 
connected clients will be disconnected. Any data that was not synced will be lost.

#### <a id="StopServerEvent">Event</a>

```typescript
interface StopServerEvent {
    /**
     *  Name of the event being emitted.
     *  Event properties are unique and found in all events.
     */
    event: string = "server/stop";

    /**
     *  Address to stop the server on.
     *  Port should be provided as well.
     */
    host: string;

    /**
     *  Timestamp of this event.
     *  Depending on the client implementation this can be used in the UI.
     */
    time: Date;
}
```

<br>

### <a id="ConnectToServer">Connect to Server</a>

Ran by the user who wishes to connect to a running server. The callers files will remain unchanged until the 
connection is aborted. The client should connect to the server on the transport layer before emitting this event.
The client is not considered *connected* until the server has received this connection event, regardless of the 
transport layer connection status.

#### <a id="ConnectServerEvent">Event</a>

```typescript
interface ConnectServerEvent {
    /**
     *  Name of the event being emitted.
     *  Event properties are unique and found in all events.
     */
    event: string = "server/connect";

    /**
     *  Address to attempt to connect to.
     *  Port should be provided as well.
     *  The default port for servers is 3270, but can be configured by the
     *  server.
     */
    host: string;

    /**
     *  Similar to a username which is provided to the server to identify 
     *  the connection/user.
     *  An ID will be returned in the response which the server will map 
     *  to this identifier.
     *  If not provided, a random identifier will be generated and provided.
     *  If the server does not implement identifiers, this value can be 
     *  null ("").
     */
    identifier: string;

    /**
     *  Password required to connect to the server.
     *  If no password is required, this should be null ("").
     */
    password: string;
}
```

#### <a id="ConnectServerResponse">Response</a>

This response will be sent to **only** the client who emitted the `ConnectServerEvent`.
The [NewClientConnectionNotification](#NewClientConnectionNotification) will be emitted to all connected clients.

```typescript
interface ConnectServerResponse {
    /**
     *  Name of the response being emitted.
     *  Response properties are unique and found in all responses.
     */
    response: string = "server/connect";

    /**
     *  Status of the connection attempt.
     */
    success: boolean;

    /**
     *  Error returned if success is false.
     *  If connection is successful, this will be null ("").
     */
    error: string;

    /**
     *  Identifier provided in the request, unless it was not in which
     *  case this will be the randomly generated identifier.
     *  If connection is unsuccessful, this will be null ("").
     */
    identifier: string;

    /**
     *  Capabilities the server has implemented.
     *  The client is expected to also impliment these capabilities.
     *  If connection fails, this will be null.
     */
    capabilities: ServerCapabilities | null;
}
```

#### <a id="NewClientConnectionNotification">Notification</a>

Once the server has received the connection request, it will emit a notification to all connected clients that a new client has connected. The server will also send the new clients identifier to all connected clients.
Assuming the server implements the capabilities for identifiers.

```typescript
interface NewClientConnectionNotification {
    /**
     *  Name of the notification being emitted.
     *  Notication properties are unique and found in all notifications.
     */
    notification: string = "client/connect";

    /**
     *  Status of the connection. If the client failed to connect, the 
     *  server will let the other clients know through this property.
     */
    status: boolean;

    /**
     *  Identifier of the client who has connected, if server implements
     *  identifiers. Otherwise the value will be null ("").
     */
    identifier: string;

    /**
     *  Timestamp of this notification.
     *  Depending on the client implementation this can be used in the UI.
     */
    time: Date;
}
```

### <a id="DisconnectFromServer">Disconnect from Server</a>

Ran by the user who wishes to disconnect from the server. The callers files will remain unchanged until the connection is re-established.
The connection is expected to be closed once this event is emitted, hence, no response is expected.

#### <a id="DisconnectServerEvent">Event</a>

```typescript
interface DisconnectServerEvent {
    /**
     *  Name of the event being emitted.
     *  Event properties are unique and found in all events.
     */
    event: string = "server/disconnect";

    /**
     *  Address to attempt to disconnect from. If the host provided
     *  does not match the host the client is connected to, this event
     *  will be ignored.
     *  Port should be provided as well.
     */
    host: string;

    /**
     *  Similar to a username which is provided to the server to identify 
     *  the connection/user. This value is used to let the server know which
     *  client is disconnecting.
     *  If the server does not implement identifiers, this value can be 
     *  blank.
     */
    identifier: string;
}
```

#### <a id="DisconnectServerNotification">Notification</a>

This notification is emitted by the server to all connected clients when a client has disconnected. It 
will also send the disconnected clients identifier to all connected clients. Assuming the server implements
the capabilities for identifiers.

```typescript
interface DisconnectServerNotification {
    /**
     *  Name of the notification being emitted.
     *  Notication properties are unique and found in all notifications.
     */
    notification: string = "client/disconnect";

    /**
     *  Similar to a username which is provided to the server to identify 
     *  the connection/user. This value is used to let the server know which
     *  client is disconnecting.
     *  If the server does not implement identifiers, this value can be 
     *  blank.
     */
    identifier: string;

    /**
     *  Timestamp of this notification.
     *  Depending on the client implementation this can be used in the UI.
     */
    time: Date;
}
```

<br>

### <a id="SyncDocument">Sync Document</a>

#### <a id="SyncDocumentEvent">Event</a>

The `document/sync` event is emitted by the server whenever a client updates the document. The server will then
send the updated document to all connected clients. The client will then update their document with the new content.
The server will also send the updated document to the client who emitted the `document/update` event. This is to 
ensure that the client has the most up-to-date document content. The files content should be in a line-by-line format.
The client will handle the data by ["diffing"](https://neovim.io/doc/user/lua.html#vim.diff) each line and updating
the clients page with the new content. This event works together with the `document/update` event to keep all the client
and the server in sync.

```typescript
interface SyncDocumentEvent {
    /**
     *  Name of the event being emitted.
     *  Event properties are unique and found in all events.
     */
    event: string = "document/sync";

    /**
     *  The content of the document that the client is sending to the server.
     *  This content should be the entire document, not just the changes.
     *  It should be in a line-by-line format.
     */
    content: string[];

    /**
     *  The name of the document that the client is sending to the server.
     *  This is relative to the server and can be used to identify the document
     *  when more than one document is being synced and updated.
     */
    document: string;

    /**
     *  Timestamp of this update.
     *  Depending on the client implementation this can be used in the UI.
     */
    time: Date;
}
```

<br>

### <a id="UpdateDocument">Update Document</a>

The `document/update` event is emitted by the client whenever a client updates the document.
The exact action that is required before emitting this event can vary depending on the client implementation.
But the client should send the entire document content to the server when emitting this event. The server will
then handle this data by ["diffing"](https://neovim.io/doc/user/lua.html#vim.diff) each line and updating the 
servers page with the new content. The server will then emit the `document/sync` event to all connected clients, 
which works basically the same way but with the roles reversed.

#### <a id="UpdateDocumentEvent">Event</a>

```typescript
interface UpdateDocumentEvent {
    /**
     *  Name of the event being emitted.
     *  Event properties are unique and found in all events.
     */
    event: string = "document/update";

    /**
     *  identifier of the client who is sending this update to the server.
     *  This value is provided by the server when the client connects.
     *  If the server does not impliment identifiers, this value can be
     *  null ("").
     */
    identifier: string;

    /**
     *  The content of the document that the client is sending to the server.
     *  This content should be the entire document, not just the changes.
     *  It should be in a line-by-line format.
     */
    content: string[];

    /**
     *  The name of the document that the client is sending to the server.
     *  This is relative to the server and can be used to identify the document
     *  when more than one document is being synced and updated.
     */
    document: string;

    /**
     *  Timestamp of this update.
     *  Depending on the server implementation this can be used in various
     *  places.
     */
    time: Date;
}
```

### <a id="OpenDocument">Open Document</a>

#### <a id="OpenDocumentEvent">Event</a>

The `document/open` event is emitted by the server whenever a new document is opened. The server will then allow 
the clients to connect to the document and begin syncing the document content. The `document/list` event can be used
to get a list of the all the documents that are currently open on the server. The name of the document is the path
of the document relative to the root in which Neovim was opened in. The content that is in the document will be sent
to the client when they connect to the document.

```typescript
interface OpenDocumentEvent {
    /**
     *  Name of the event being emitted.
     *  Event properties are unique and found in all events.
     */
    event: string = "document/open";

    /**
     *  The name of the document that the server is opening.
     *  This is relative to the server and can be used to identify the document
     *  when more than one document is being synced and updated.
     *  Relative to the root in which Neovim was opened in.
     */
    document: string;

    /**
     *  Timestamp of this update.
     *  Depending on the implementation this can be used in various
     *  places.
     */
    time: Date;
}
```

### <a id="CloseDocument">Close Document</a>

#### <a id="CloseDocumentEvent">Event</a>

The `document/close` event is emitted by the server whenever a new document is closed. The server will then stop
any connections to the document and the clients will no longer be able to connect to the document. The `document/list`
event can be used to get a list of the all the documents that are currently open on the server. The name of the document 
is the path of the document relative to the root in which Neovim was opened in.

```typescript
interface CloseDocumentEvent {
    /**
     *  Name of the event being emitted.
     *  Event properties are unique and found in all events.
     */
    event: string = "document/close";

    /**
     *  The name of the document that the server is closed.
     *  This is relative to the server and can be used to identify the document
     *  when more than one document is being synced and updated.
     *  Relative to the root in which Neovim was opened in.
     */
    document: string;

    /**
     *  Timestamp of this update.
     *  Depending on the implementation this can be used in various
     *  places.
     */
    time: Date;
}
```

### <a id="ListDocuments">List Documents</a>

#### <a id="ListDocumentsEvent">Event</a>

The `document/list` event is emitted by any client who needs to get a list of the open documents on the server.
The server will then send a list of the open documents to the client. The name of the document is the path of the document 
relative to the root in which Neovim was opened in.

```typescript
interface ListDocumentEvent {
    /**
     *  Name of the event being emitted.
     *  Event properties are unique and found in all events.
     */
    event: string = "document/list";

    /**
     *  Identifier of the client who is sending this event to the server.
     *  This value is provided by the server when the client connects.
     *  If the server does not impliment identifiers, this value can be
     *  null ("").
     */
    identifier: string;
}
```

#### <a id="ListDocumentsResponse">Response</a>

This is the response returned by the server a client emits the `document/list` event.

```typescript
interface ListDocumentResponse {
    /**
     *  Name of the response being emitted.
     *  Event properties are unique and found in all responses.
     */
    response: string = "document/list";

    /**
     *  Status of the response.
     */
    success: boolean;

    /**
     *  List of the open documents on the server. The name of the documents
     *  is the path of the document relative to the root in which Neovim was
     *  opened in. Any closed buffers will not be returned in this list.
     */
    buffer: string[];

    /**
     *  Timestamp of this update.
     *  Depending on the implementation this can be used in various
     *  places.
     */
    time: Date;
}

```

<br>

## <a id="Server&ClientSharedTypes">Server & Client Shared Types</a>

### <a id="ServerCapabilities">Server Capabilities</a>

Capabilities are features that the server can implement. They are defined by the server and can be used by the client. The client must also implement the capabilities to allow for the proper use of the server capabilities. 

```typescript
interface ServerCapabilities {
    /**
     *  Should the server allow multiple users to edit the same file at 
     *  the same time.
     *  Value provided determines the time between each sync event in
     *  milliseconds.
     *  When 0, clients will be put into a read-only mode.
     *  Default is 1000ms.
     */
    document_sync: integer = 1000;

    /**
     *  Should the server send and receive document data in a compressed
     *  format.
     *  If this value is null (""), compression will not be supported.
     *  Values can be "LZMA", "GZIP", "DEFLATE", "ZLIB", or any other 
     *  algorithm that the server and client both support.
     *  Default is "", which will not implement compression.
     */
    compression: string = "";

    /**
     *  Should the server display the users identifier in the document.
     *  Default is true.
     */
    identifiers: boolean = true;

    /**
     *  Should the server display the cursor of the users in the document.
     *  Value provided determines the time between each sync event in
     *  milliseconds.
     *  When 0, server will not accept the clients cursor location.
     *  Default is 1000ms.
     */
    cursor_sync: integer = 1000;

    /**
     *  Should the server display the number of clients connected to 
     *  the server.
     *  Default is true.
     */
    client_count: boolean = true;
}
```
