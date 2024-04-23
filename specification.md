# Specification 

### Version 0.0.1

<br>

**What is the document sync protocol?**

    The document sync protocol allows two or more users to edit the same file at the same time. 

**How does it work?** 

    Not sure yet :)

## Events


#### [Start Server](#Start-Server)

Ran by the user who wishes to start a server. Senders file content will be updated by the connected users, assuming the server implements such capabilities.

##### Event

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
     *  Define the capbilities the server will implement.
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

##### Response

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

#### [Connect to Server](#Connect-to-Server)

Ran by the user who wishes to connect to a running server. The callers files will remain unchanged until the connection is aborted.

##### Event

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
     *  The default port for servers is 3270, but can be configured by the server.
     */
    host: string;

    /**
     *  Similiar to a username which is provided to the server to identify the connection/user.
     *  An ID will be returned in the response which the server will map to this identifier.
     */
    identifier: string;

    /**
     *  Password required to connect to the server.
     *  If no password is required, this should be ommmitted.
     *
     *  !!! Should this be null or optional? 
     */
    password?: string;
}
```

##### Response

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
     *  ID provided for the identifier provided in the request.
     *  This ID will be used to map the connection to the user.
     *  If connection is unsuccessful, this will be null.
     */
    id: string | null;

    /**
     *  Capabilities the server has implemented.
     *  The client is expected to also impliment these capabilities.
     *  If connection fails, this will be null.
     */
    capabilities: ServerCapabilities | null;
}
```

## Types

#### [Server Capabilities](#Server-Capabilities)

Capabilities are features that the server can implement. They are defined by the server and can be used by the client. The client must also implement the capabilities to allow for the proper use of the server capabilities. 

```typescript
interface ServerCapabilities {
    /**
     *  Should the server allow multiple users to edit the same file at the same time.
     *  When false, clients will be put into a read-only mode.
     */
    documentSync: boolean;

    /**
     *  Should the server display the users identifier in the document.
     */
    identifiers: boolean;

    /**
     *  Should the server display the cursor of the users in the document.
     */
    cursorSync: boolean;

    /**
     *  Should the server display the number of clients connected to the server.
     */
    clientCount: boolean;
}
```
