/ q gateway.q -p 8080

services: ([]name:enlist`rdb; address:enlist `:localhost:9000; handle:enlist 0Ni);

connectServices: {[serviceName]
    $[serviceName = `;
        / open handles for all disconnected services
        update handle: @[hopen; ; 0Ni] each address from `services where handle = 0Ni;

        / open handles for all disconnected serviceName
        update handle: @[hopen; ; 0Ni] each address from `services where name = serviceName, handle = 0Ni
    ]
 };
getServiceHandle: {[serviceName]
    / if the allocated service is not connected
    if [null h: first exec handle from services where name = serviceName, handle <> 0Ni;
        connectServices serviceName;    / connect to the services

        / try get the service handle again
        h: first exec handle from services where name = serviceName, handle <> 0Ni
    ];
    h
 };


callback: {[clientHandle; result] 
    / send back deferred response to client
    -30!clientHandle, result 
 };
/ user.q) h (`request; `rdb; "query")
request: {[serviceName; query]
    / a function that services call after getting the result
    remoteFunc: {[clientHandle; query]
        
        / tell services to call `callback function given clientHandle and query result
        neg[.z.w](`callback; clientHandle; @[(0b;)value@; query; {[error] (1b; error)}])
    };

    / return error message if all services are unavailable
    if [null h: getServiceHandle serviceName;
        :`$"service unavailable: ", string serviceName;
    ];

    neg[h] (remoteFunc; .z.w; query);
    -30!(::);       / wait for deferred response
 };


connectServices`;   / connect all services in services