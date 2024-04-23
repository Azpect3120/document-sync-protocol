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

##### Request

```
export type StartServerEvent {
    /**
     *  Name of the event being emitted.
     *  Event properties are unique and found in all events.
     */
    event: string = "server/start";

    /**
     *  Address to start the server on.
     *  Port should be provided as well.
     */
    host: string;

    /**
     *  List of capbilities the server will implement.
     *  If not provided, the server will not have any capbilities.
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

}
```

##### Response

```
export type StartServerResponse {
    /**
     *  Address the server is running on.
     *  Port should be provided as well.
     */
    host: string;

    /**
     *  Status of the connection.
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
}
```

#### [Connect to Server](#Connect-to-Server)

Ran by the user who wishes to connect to a running server. The callers files will remain unchanged until the connection is aborted.

##### Request

```
export type ConnectServerEvent {
    /**
     *  Name of the event being emitted.
     *  Event properties are unique and found in all events.
     */
    event: string = "server/connect";

    /**
     *  Address to attempt to connect to.
     *  Port should be provided as well.
     */
    host: string;

    /**
     *  Similiar to a username which is provided to the server to identify the connection/user.
     *  An ID will be returned in the response which the server will map to this identifier.
     */
    identifier: string;
}
```

##### Response

```
export type ConnectServerResponse {

}
```

## Types

#### [Server Capabilities](#Server-Capabilities)

Capabilities are features that the server can implement. They are defined by the server and can be used by the client.

```
export type ServerCapabilities {
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
}
```
