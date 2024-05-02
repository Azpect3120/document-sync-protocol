# Specification 

### Version `0.0.1`

<br>

**What is the document sync protocol?**

    The document sync protocol allows two or more users to edit the same file at the same time. 

**How does it work?** 

    TCP server will be started by the server user and the clients will establish a TCP connection to the server.
    When the connection is successful, the capabilities will be sent from the server and the client will implement the functionality to allow syncing between the server and connected clients.

<br>

## Events

### [Start Server](#Start-Server)

Ran by the user who wishes to start a server. Senders file content will be updated by the connected users, assuming the server implements such capabilities.

NOTE: `Event` is not really the right word to describe what this action. `Function` may be a better word to describe how this works. The server must first run a function that implements the following interface which will start up the server, then events can begin.

### Event

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
     *  If not provided, the server will fail to start.
     */
    capabilities: ServerCapabilities;

    /**
     *  Max number of clients that can connect to the server.
     *  Can be upgraded later to allow for more connections.
     *  If not provided, the server will allow unlimited connections.
     */
    maxConnections?: integer;

    /**
     *  Password required to connect to the server.
     *  If not provided, the server will not require a password.
     */
    password?: string;

    /**
     *  Time in milliseconds before syncing the document.
     *  If not provided, the server will sync the document every 1000ms.
     */
    timeout?: integer;
}
```

### Response

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

### [Connect to Server](#Connect-to-Server)

Ran by the user who wishes to connect to a running server. The callers files will remain unchanged until the connection is aborted.

NOTE: `Event` is not really the right word to describe what this action. `Function` may be a better word to describe how this works. The client must first run a function that implements the following interface which will connect to a running server and then the client may begin listening to events and sending back data.

### Event

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
     *  omitted.
     */
    identifier?: string;

    /**
     *  Password required to connect to the server.
     *  If no password is required, this should be ommmitted.
     *
     *  !!! Should this be null or optional? 
     */
    password?: string;
}
```

### Response

```typescript
interface ConnectServerResponse {
    /**
     *  Status of the connection attempt.
     */
    success: boolean;

    /**
     *  Error returned if success is false.
     *  If connection is successful, this will be null.
     */
    error: string | null;

    /**
     *  Identifier provided in the request, unless it was not in which
     *  case this will be the randomly generated identifier.
     *  If connection is unsuccessful, this will be null.
     */
    identifier: string | null;

    /**
     *  Capabilities the server has implemented.
     *  The client is expected to also impliment these capabilities.
     *  If connection fails, this will be null.
     */
    capabilities: ServerCapabilities | null;
}
```

### [Disconnect from Server](#Disconnect-from-Server)

Ran by the user who wishes to disconnect from the server. The callers files will remain unchanged until the connection is re-established. The connection is expected to be closed once this event is emitted, hence, no response is expected.

### Event

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
     *  omitted.
     */
    identifier?: string;
}
```

No response is expected from the server to the client upon emitting this event.

### [Sync Document](#Sync-Document)

Event is emitted by the server which sends back the document to each client. Client event is emitted by the client to the server. The time between syncs on the client side is determined by the client's implementation. The time between the syncs on the server side is determined by the server when it is spawned.


### Event
```typescript
interface SyncDocumentEvent {
    /**
     *  Name of the event being emitted.
     *  Event properties are unique and found in all events.
     */
    event: string = "document/sync";

    /**
     *  Defines if the document provided a partial or an entire document.
     *  If false, the clients entire document can be overwritten by the 
     *  new data.
     */ 
    partial: boolean;

    /**
     *  Synced document data. 
     *  Compression algorithms can be used but only if both the client and 
     *  server support the implementation, which is defined in the server 
     *  capabilities.
     *  If a partial is provided the location property should be used by 
     *  the client to determine the location to swap the data into.
     */
    content: string[];

    /**
     *  Name of the document that is being synced.
     *  When multi-file support is implemented this will be a bigger deal
     *  but for the time being it is just used to ensure the right document
     *  is being sent and received.
     */
    document: string;

    /**
     *  The array if values will contain line numbers, the first index 
     *  value will define the start line and the second will define the
     *  end line.
     *  If the data being sent is not in a partial format then this value
     *  can be omitted. But if it is a partial, the and this value is 
     *  omitted, the content will be ignored by the client until the next
     *  successful sync. An error here will result in an unsuccessful sync.
     */
    location: integer[2] | null;

    /**
     *  Timestamp of this update.
     *  Depending on the client implementation this can be used in the UI.
     */
    time: Date;
}
```

No response is expected from the client to the server upon emitting this event.


### [Update Document](#Update-Document)

Event is emitted by the client to the server. The time between syncs on the client side is determined by the client's implementation. The action that triggers the event is also determined by the client's implementation.

Client events can be emitted at any point but the server event will be emitted only when the timer has completed a full cycle. If the server sync timer is reduced the clients data will be updated quicker.

### Event
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
     *  omitted.
     */
    identifier: string | null;

    /**
     *  Defines if the document provided a partial or an entire document.
     *  If false, the servers entire document can be overwritten by the 
     *  new data.
     */ 
    partial: boolean;

    /**
     *  Updated document data. 
     *  Compression algorithms can be used but only if both the client and 
     *  server support the implementation, which is defined in the server 
     *  capabilities.
     *  If a partial is provided the location property should be used by 
     *  the client to determine the location to swap the data into.
     */
    content: string[];

    /**
     *  Name of the document that is being updated.
     *  When multi-file support is implemented this will be a bigger deal
     *  but for the time being it is just used to ensure the right document
     *  is being sent and received.
     */
    document: string;

    /**
     *  The array if values will contain line numbers, the first index 
     *  value will define the start line and the second will define the
     *  end line.
     *  If the data being sent is not in a partial format then this value
     *  can be omitted. But if it is a partial, the and this value is 
     *  omitted, the content will be ignored by the server until the next
     *  successful update. An error here will result in an unsuccessful 
     *  update.
     */
    location: integer[2] | null;

    /**
     *  Timestamp of this update.
     *  Depending on the server implementation this can be used in various
     *  places.
     */
    time: Date;
}
```

<br>

## Types

### [Server Capabilities](#Server-Capabilities)

Capabilities are features that the server can implement. They are defined by the server and can be used by the client. The client must also implement the capabilities to allow for the proper use of the server capabilities. 

```typescript
interface ServerCapabilities {
    /**
     *  Should the server allow multiple users to edit the same file at 
     *  the same time.
     *  Value provided determines the time between each sync event in
     *  milliseconds.
     *  When 0, clients will be put into a read-only mode.
     */
    document_sync: integer;

    /**
     *  Should the server send and receive document data in a compressed
     *  format.
     *  If this value is omitted, compression will not be supported.
     */
    compression: string = "LZMA" | "GZIP" | "DEFLATE" | "ZLIB" | null;

    /**
     *  Should the server display the users identifier in the document.
     */
    identifiers: boolean;

    /**
     *  Should the server display the cursor of the users in the document.
     *  Value provided determines the time between each sync event in
     *  milliseconds.
     *  When 0, server will not accept the clients cursor location.
     */
    cursor_sync: integer;

    /**
     *  Should the server display the number of clients connected to 
     *  the server.
     */
    client_count: boolean;
}
```
