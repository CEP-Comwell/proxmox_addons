2025-11-05T00:01:13-08:00 INFO shared/relay/client/picker.go:71: try to connecting to relay server: rels://relay.netbird.io:443
2025-11-05T00:01:13-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:168: create new relay connection: local peerID: R48lbpXc9oXQL+cRAL2/EMSd6HTtg70DyrJsrG3pmBM=, local peer hashedID: sha-wZTVe8xMHaw36fCmuWtSeeNTaSc17TAjBApRyAsQGOk=
2025-11-05T00:01:13-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:174: connecting to relay server
2025-11-05T00:01:13-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via quic
2025-11-05T00:01:13-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via WS
2025-11-05T00:01:32-08:00 ERRO client/grpc/dialer_generic.go:39: Failed to dial: dial tcp: lookup signal.netbird.io: i/o timeout
2025-11-05T00:01:32-08:00 INFO ./caller_not_available:0: 2025/11/05 00:01:32 WARNING: [core] [Channel #6 SubChannel #7]grpc: addrConn.createTransport failed to connect to {Addr: "signal.netbird.io:443", ServerName: "signal.netbird.io:443", BalancerAttributes: {"<%!p(pickfirstleaf.managedByPickfirstKeyType={})>": "<%!p(bool=true)>" }}. Err: connection error: desc = "transport: Error while dialing: nbnet.NewDialer().DialContext: dial tcp: lookup signal.netbird.io: i/o timeout"
2025-11-05T00:01:33-08:00 ERRO shared/relay/client/dialer/quic/quic.go:56: failed to resolve UDP address: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:42389->9.9.9.9:53: i/o timeout
2025-11-05T00:01:33-08:00 ERRO shared/relay/client/dialer/ws/ws.go:48: failed to dial to Relay server 'wss://relay.netbird.io:443': failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:43446->9.9.9.9:53: i/o timeout
2025-11-05T00:01:33-08:00 ERRO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via quic: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:42389->9.9.9.9:53: i/o timeout
2025-11-05T00:01:33-08:00 ERRO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via WS: failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:43446->9.9.9.9:53: i/o timeout
2025-11-05T00:01:33-08:00 ERRO shared/relay/client/guard.go:59: failed to pick new Relay server: failed to connect to any relay server: all attempts failed
2025-11-05T00:01:33-08:00 INFO shared/relay/client/guard.go:92: try to pick up a new Relay server
2025-11-05T00:01:33-08:00 INFO shared/relay/client/picker.go:71: try to connecting to relay server: rels://relay.netbird.io:443
2025-11-05T00:01:33-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:168: create new relay connection: local peerID: R48lbpXc9oXQL+cRAL2/EMSd6HTtg70DyrJsrG3pmBM=, local peer hashedID: sha-wZTVe8xMHaw36fCmuWtSeeNTaSc17TAjBApRyAsQGOk=
2025-11-05T00:01:33-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:174: connecting to relay server
2025-11-05T00:01:33-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via quic
2025-11-05T00:01:33-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via WS
2025-11-05T00:01:46-08:00 INFO client/cmd/root.go:196: shutdown signal received
2025-11-05T00:01:46-08:00 ERRO shared/relay/client/guard.go:59: failed to pick new Relay server: failed to connect to any relay server: context canceled
2025-11-05T00:01:46-08:00 INFO shared/relay/client/guard.go:92: try to pick up a new Relay server
2025-11-05T00:01:46-08:00 WARN shared/signal/client/grpc.go:154: disconnected from the Signal Exchange due to an error: rpc error: code = Canceled desc = latest balancer error: connection error: desc = "transport: Error while dialing: nbnet.NewDialer().DialContext: dial tcp: lookup signal.netbird.io: i/o timeout"
2025-11-05T00:01:46-08:00 ERRO shared/signal/client/grpc.go:186: exiting the Signal service connection retry loop due to the unrecoverable error: context canceled
2025-11-05T00:01:46-08:00 INFO client/internal/engine.go:981: connecting to Management Service updates stream
2025-11-05T00:01:46-08:00 INFO client/internal/engine.go:1751: Network monitor is disabled, not starting
2025-11-05T00:01:46-08:00 ERRO shared/relay/client/guard.go:59: failed to pick new Relay server: failed to connect to any relay server: context canceled
2025-11-05T00:01:46-08:00 INFO client/internal/connect.go:283: Netbird engine started, the IP is: 100.100.120.19/16
2025-11-05T00:01:46-08:00 INFO shared/relay/client/picker.go:71: try to connecting to relay server: rels://relay.netbird.io:443
2025-11-05T00:01:46-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:168: create new relay connection: local peerID: R48lbpXc9oXQL+cRAL2/EMSd6HTtg70DyrJsrG3pmBM=, local peer hashedID: sha-wZTVe8xMHaw36fCmuWtSeeNTaSc17TAjBApRyAsQGOk=
2025-11-05T00:01:46-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:174: connecting to relay server
2025-11-05T00:01:46-08:00 INFO client/internal/engine.go:289: Network monitor: stopped
2025-11-05T00:01:46-08:00 ERRO client/internal/dns/server.go:346: failed to restore host DNS settings: restoring /etc/resolv.conf from /etc/resolv.conf.original.netbird: checking stats for /etc/resolv.conf.original.netbird file when copying it. Error: stat /etc/resolv.conf.original.netbird: no such file or directory
2025-11-05T00:01:46-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via quic
2025-11-05T00:01:46-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via WS
2025-11-05T00:01:46-08:00 INFO client/internal/wg_iface_monitor.go:50: Interface monitor: watching wt0 (index: 57)
2025-11-05T00:01:46-08:00 INFO client/internal/wg_iface_monitor.go:58: Interface monitor: stopped for wt0
2025-11-05T00:01:46-08:00 WARN client/internal/engine.go:495: WireGuard interface monitor: wg interface monitor stopped: context canceled
2025-11-05T00:01:46-08:00 INFO client/internal/routemanager/manager.go:305: Routing cleanup complete
2025-11-05T00:01:46-08:00 ERRO shared/management/client/grpc.go:278: failed while getting Management Service public key: rpc error: code = Canceled desc = context canceled
2025-11-05T00:01:46-08:00 WARN shared/management/client/grpc.go:137: exiting the Management service connection retry loop due to the unrecoverable error: context canceled
2025-11-05T00:01:47-08:00 ERRO client/iface/udpmux/universal.go:98: error while reading packet: shared socked stopped
2025-11-05T00:01:47-08:00 INFO client/iface/iface.go:309: interface wt0 has been removed
2025-11-05T00:01:47-08:00 INFO client/internal/engine.go:339: stopped Netbird Engine
2025-11-05T00:01:47-08:00 INFO client/server/server.go:830: service is down
2025-11-05T00:01:47-08:00 INFO client/internal/connect.go:305: stopped NetBird client
2025-11-05T00:01:47-08:00 ERRO client/grpc/dialer_generic.go:39: Failed to dial: dial tcp: lookup signal.netbird.io: operation was canceled
2025-11-05T00:01:47-08:00 INFO ./caller_not_available:0: 2025/11/05 00:01:47 WARNING: [core] [Channel #6 SubChannel #7]grpc: addrConn.createTransport failed to connect to {Addr: "signal.netbird.io:443", ServerName: "signal.netbird.io:443", BalancerAttributes: {"<%!p(pickfirstleaf.managedByPickfirstKeyType={})>": "<%!p(bool=true)>" }}. Err: connection error: desc = "transport: Error while dialing: nbnet.NewDialer().DialContext: dial tcp: lookup signal.netbird.io: operation was canceled"
2025-11-05T00:01:48-08:00 ERRO shared/relay/client/dialer/quic/quic.go:56: failed to resolve UDP address: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:52208->9.9.9.9:53: i/o timeout
2025-11-05T00:01:48-08:00 ERRO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via quic: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:52208->9.9.9.9:53: i/o timeout
2025-11-05T00:01:48-08:00 ERRO shared/relay/client/dialer/quic/quic.go:56: failed to resolve UDP address: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:52208->9.9.9.9:53: i/o timeout
2025-11-05T00:01:48-08:00 ERRO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via quic: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:52208->9.9.9.9:53: i/o timeout
2025-11-05T00:01:48-08:00 ERRO shared/relay/client/dialer/ws/ws.go:48: failed to dial to Relay server 'wss://relay.netbird.io:443': failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:46455->9.9.9.9:53: i/o timeout
2025-11-05T00:01:48-08:00 ERRO shared/relay/client/dialer/ws/ws.go:48: failed to dial to Relay server 'wss://relay.netbird.io:443': failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:46455->9.9.9.9:53: i/o timeout
2025-11-05T00:01:48-08:00 ERRO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via WS: failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:46455->9.9.9.9:53: i/o timeout
2025-11-05T00:01:48-08:00 ERRO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via WS: failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:46455->9.9.9.9:53: i/o timeout
2025-11-05T00:01:49-08:00 INFO client/cmd/service_controller.go:100: stopped NetBird service
2025-11-05T00:03:49-08:00 INFO client/cmd/service_controller.go:27: starting NetBird service
2025-11-05T00:03:49-08:00 INFO client/cmd/service_controller.go:74: started daemon server: /var/run/netbird.sock
2025-11-05T00:03:49-08:00 INFO client/internal/connect.go:124: starting NetBird client version 0.59.11 on linux/amd64
2025-11-05T00:03:49-08:00 INFO client/net/env_linux.go:70: system supports advanced routing
2025-11-05T00:03:49-08:00 INFO client/internal/connect.go:265: connecting to the Relay service(s): rels://relay.netbird.io:443
2025-11-05T00:03:49-08:00 INFO shared/relay/client/picker.go:71: try to connecting to relay server: rels://relay.netbird.io:443
2025-11-05T00:03:49-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:168: create new relay connection: local peerID: R48lbpXc9oXQL+cRAL2/EMSd6HTtg70DyrJsrG3pmBM=, local peer hashedID: sha-wZTVe8xMHaw36fCmuWtSeeNTaSc17TAjBApRyAsQGOk=
2025-11-05T00:03:49-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:174: connecting to relay server
2025-11-05T00:03:49-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via quic
2025-11-05T00:03:49-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via WS
2025-11-05T00:03:49-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:91: successfully dialed via: WS
2025-11-05T00:03:49-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:77: connection attempt aborted via: quic
2025-11-05T00:03:49-08:00 INFO [relay: rels://streamline-us-sjo1-2.relay.netbird.io:443] shared/relay/client/client.go:196: relay connection established
2025-11-05T00:03:49-08:00 INFO shared/relay/client/picker.go:89: connected to Relay server: rels://relay.netbird.io:443
2025-11-05T00:03:49-08:00 INFO shared/relay/client/picker.go:63: chosen home Relay server: rels://relay.netbird.io:443
2025-11-05T00:03:49-08:00 INFO client/internal/engine.go:268: I am: R48lbpXc9oXQL+cRAL2/EMSd6HTtg70DyrJsrG3pmBM=
2025-11-05T00:03:50-08:00 INFO client/iface/wgproxy/ebpf/proxy.go:97: local wg proxy listening on: 3128
2025-11-05T00:03:50-08:00 INFO client/iface/wgproxy/factory_kernel.go:31: WireGuard Proxy Factory will produce eBPF proxy
2025-11-05T00:03:50-08:00 INFO client/internal/routemanager/manager.go:235: Routing setup complete
2025-11-05T00:03:50-08:00 INFO client/firewall/create_linux.go:70: creating an iptables firewall manager
2025-11-05T00:03:50-08:00 INFO client/internal/dns/host_unix.go:54: System DNS manager discovered: file
2025-11-05T00:03:50-08:00 INFO client/internal/conn_mgr.go:62: lazy connection manager is disabled
2025-11-05T00:04:00-08:00 WARN shared/signal/client/grpc.go:154: disconnected from the Signal Exchange due to an error: didn't receive a registration header from the Signal server whille connecting to the streams
2025-11-05T00:04:20-08:00 ERRO client/grpc/dialer_generic.go:39: Failed to dial: dial tcp: lookup signal.netbird.io: i/o timeout
2025-11-05T00:04:20-08:00 INFO ./caller_not_available:0: 2025/11/05 00:04:20 WARNING: [core] [Channel #6 SubChannel #7]grpc: addrConn.createTransport failed to connect to {Addr: "signal.netbird.io:443", ServerName: "signal.netbird.io:443", BalancerAttributes: {"<%!p(pickfirstleaf.managedByPickfirstKeyType={})>": "<%!p(bool=true)>" }}. Err: connection error: desc = "transport: Error while dialing: nbnet.NewDialer().DialContext: dial tcp: lookup signal.netbird.io: i/o timeout"
2025-11-05T00:04:24-08:00 ERRO [relay: rels://streamline-us-sjo1-2.relay.netbird.io:443] shared/relay/client/client.go:511: health check timeout
2025-11-05T00:04:24-08:00 INFO [relay: rels://streamline-us-sjo1-2.relay.netbird.io:443] shared/relay/client/client.go:370: start to Relay read loop exit
2025-11-05T00:04:24-08:00 INFO [relay: rels://streamline-us-sjo1-2.relay.netbird.io:443] shared/relay/client/client.go:597: closing all peer connections
2025-11-05T00:04:24-08:00 INFO [relay: rels://streamline-us-sjo1-2.relay.netbird.io:443] shared/relay/client/client.go:605: waiting for read loop to close
2025-11-05T00:04:24-08:00 INFO [relay: rels://streamline-us-sjo1-2.relay.netbird.io:443] shared/relay/client/client.go:607: relay connection closed
2025-11-05T00:04:26-08:00 INFO shared/relay/client/guard.go:82: try to reconnect to Relay server: rels://relay.netbird.io:443
2025-11-05T00:04:26-08:00 INFO [relay: rels://streamline-us-sjo1-2.relay.netbird.io:443] shared/relay/client/client.go:174: connecting to relay server
2025-11-05T00:04:26-08:00 INFO [relay: rels://streamline-us-sjo1-2.relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via quic
2025-11-05T00:04:26-08:00 INFO [relay: rels://streamline-us-sjo1-2.relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via WS
2025-11-05T00:04:41-08:00 ERRO client/grpc/dialer_generic.go:39: Failed to dial: dial tcp: lookup signal.netbird.io: i/o timeout
2025-11-05T00:04:41-08:00 INFO ./caller_not_available:0: 2025/11/05 00:04:41 WARNING: [core] [Channel #6 SubChannel #7]grpc: addrConn.createTransport failed to connect to {Addr: "signal.netbird.io:443", ServerName: "signal.netbird.io:443", BalancerAttributes: {"<%!p(pickfirstleaf.managedByPickfirstKeyType={})>": "<%!p(bool=true)>" }}. Err: connection error: desc = "transport: Error while dialing: nbnet.NewDialer().DialContext: dial tcp: lookup signal.netbird.io: i/o timeout"
2025-11-05T00:04:46-08:00 ERRO shared/relay/client/dialer/quic/quic.go:56: failed to resolve UDP address: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:45458->9.9.9.9:53: i/o timeout
2025-11-05T00:04:46-08:00 ERRO shared/relay/client/dialer/ws/ws.go:48: failed to dial to Relay server 'wss://relay.netbird.io:443': failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:58681->9.9.9.9:53: i/o timeout
2025-11-05T00:04:46-08:00 ERRO [relay: rels://streamline-us-sjo1-2.relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via quic: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:45458->9.9.9.9:53: i/o timeout
2025-11-05T00:04:46-08:00 ERRO [relay: rels://streamline-us-sjo1-2.relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via WS: failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:58681->9.9.9.9:53: i/o timeout
2025-11-05T00:04:46-08:00 ERRO shared/relay/client/guard.go:85: failed to reconnect to relay server: failed to dial to Relay server on any protocol
2025-11-05T00:04:46-08:00 INFO shared/relay/client/guard.go:92: try to pick up a new Relay server
2025-11-05T00:04:46-08:00 INFO shared/relay/client/picker.go:71: try to connecting to relay server: rels://relay.netbird.io:443
2025-11-05T00:04:46-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:168: create new relay connection: local peerID: R48lbpXc9oXQL+cRAL2/EMSd6HTtg70DyrJsrG3pmBM=, local peer hashedID: sha-wZTVe8xMHaw36fCmuWtSeeNTaSc17TAjBApRyAsQGOk=
2025-11-05T00:04:46-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:174: connecting to relay server
2025-11-05T00:04:46-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via quic
2025-11-05T00:04:46-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via WS
2025-11-05T00:05:03-08:00 ERRO client/grpc/dialer_generic.go:39: Failed to dial: dial tcp: lookup signal.netbird.io: i/o timeout
2025-11-05T00:05:03-08:00 INFO ./caller_not_available:0: 2025/11/05 00:05:03 WARNING: [core] [Channel #6 SubChannel #7]grpc: addrConn.createTransport failed to connect to {Addr: "signal.netbird.io:443", ServerName: "signal.netbird.io:443", BalancerAttributes: {"<%!p(pickfirstleaf.managedByPickfirstKeyType={})>": "<%!p(bool=true)>" }}. Err: connection error: desc = "transport: Error while dialing: nbnet.NewDialer().DialContext: dial tcp: lookup signal.netbird.io: i/o timeout"
2025-11-05T00:05:06-08:00 ERRO shared/relay/client/dialer/quic/quic.go:56: failed to resolve UDP address: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:43872->9.9.9.9:53: i/o timeout
2025-11-05T00:05:06-08:00 ERRO shared/relay/client/dialer/ws/ws.go:48: failed to dial to Relay server 'wss://relay.netbird.io:443': failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:35933->9.9.9.9:53: i/o timeout
2025-11-05T00:05:06-08:00 ERRO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via quic: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:43872->9.9.9.9:53: i/o timeout
2025-11-05T00:05:06-08:00 ERRO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via WS: failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:35933->9.9.9.9:53: i/o timeout
2025-11-05T00:05:06-08:00 ERRO shared/relay/client/guard.go:59: failed to pick new Relay server: failed to connect to any relay server: all attempts failed
2025-11-05T00:05:06-08:00 INFO shared/relay/client/guard.go:92: try to pick up a new Relay server
2025-11-05T00:05:06-08:00 INFO shared/relay/client/picker.go:71: try to connecting to relay server: rels://relay.netbird.io:443
2025-11-05T00:05:06-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:168: create new relay connection: local peerID: R48lbpXc9oXQL+cRAL2/EMSd6HTtg70DyrJsrG3pmBM=, local peer hashedID: sha-wZTVe8xMHaw36fCmuWtSeeNTaSc17TAjBApRyAsQGOk=
2025-11-05T00:05:06-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:174: connecting to relay server
2025-11-05T00:05:06-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via quic
2025-11-05T00:05:06-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via WS
2025-11-05T00:05:19-08:00 INFO client/cmd/root.go:196: shutdown signal received
2025-11-05T00:05:19-08:00 ERRO shared/relay/client/guard.go:59: failed to pick new Relay server: failed to connect to any relay server: context canceled
2025-11-05T00:05:19-08:00 INFO client/internal/engine.go:981: connecting to Management Service updates stream
2025-11-05T00:05:19-08:00 INFO client/internal/engine.go:1751: Network monitor is disabled, not starting
2025-11-05T00:05:19-08:00 WARN shared/signal/client/grpc.go:154: disconnected from the Signal Exchange due to an error: rpc error: code = Canceled desc = latest balancer error: connection error: desc = "transport: Error while dialing: nbnet.NewDialer().DialContext: dial tcp: lookup signal.netbird.io: i/o timeout"
2025-11-05T00:05:19-08:00 ERRO shared/signal/client/grpc.go:186: exiting the Signal service connection retry loop due to the unrecoverable error: context canceled
2025-11-05T00:05:19-08:00 INFO client/internal/connect.go:283: Netbird engine started, the IP is: 100.100.120.19/16
2025-11-05T00:05:19-08:00 INFO client/internal/engine.go:289: Network monitor: stopped
2025-11-05T00:05:19-08:00 ERRO client/internal/dns/server.go:346: failed to restore host DNS settings: restoring /etc/resolv.conf from /etc/resolv.conf.original.netbird: checking stats for /etc/resolv.conf.original.netbird file when copying it. Error: stat /etc/resolv.conf.original.netbird: no such file or directory
2025-11-05T00:05:19-08:00 INFO client/internal/wg_iface_monitor.go:50: Interface monitor: watching wt0 (index: 58)
2025-11-05T00:05:19-08:00 INFO client/internal/wg_iface_monitor.go:58: Interface monitor: stopped for wt0
2025-11-05T00:05:19-08:00 WARN client/internal/engine.go:495: WireGuard interface monitor: wg interface monitor stopped: context canceled
2025-11-05T00:05:19-08:00 INFO client/internal/routemanager/manager.go:305: Routing cleanup complete
2025-11-05T00:05:19-08:00 ERRO shared/management/client/grpc.go:278: failed while getting Management Service public key: rpc error: code = Canceled desc = context canceled
2025-11-05T00:05:19-08:00 WARN shared/management/client/grpc.go:137: exiting the Management service connection retry loop due to the unrecoverable error: context canceled
2025-11-05T00:05:20-08:00 ERRO client/iface/udpmux/universal.go:98: error while reading packet: shared socked stopped
2025-11-05T00:05:20-08:00 INFO client/iface/iface.go:309: interface wt0 has been removed
2025-11-05T00:05:20-08:00 INFO client/internal/engine.go:339: stopped Netbird Engine
2025-11-05T00:05:20-08:00 INFO client/server/server.go:830: service is down
2025-11-05T00:05:20-08:00 INFO client/internal/connect.go:305: stopped NetBird client
2025-11-05T00:05:20-08:00 ERRO client/grpc/dialer_generic.go:39: Failed to dial: dial tcp: lookup signal.netbird.io: operation was canceled
2025-11-05T00:05:20-08:00 INFO ./caller_not_available:0: 2025/11/05 00:05:20 WARNING: [core] [Channel #6 SubChannel #7]grpc: addrConn.createTransport failed to connect to {Addr: "signal.netbird.io:443", ServerName: "signal.netbird.io:443", BalancerAttributes: {"<%!p(pickfirstleaf.managedByPickfirstKeyType={})>": "<%!p(bool=true)>" }}. Err: connection error: desc = "transport: Error while dialing: nbnet.NewDialer().DialContext: dial tcp: lookup signal.netbird.io: operation was canceled"
2025-11-05T00:05:21-08:00 ERRO shared/relay/client/dialer/ws/ws.go:48: failed to dial to Relay server 'wss://relay.netbird.io:443': failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:40721->9.9.9.9:53: i/o timeout
2025-11-05T00:05:21-08:00 ERRO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via WS: failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:40721->9.9.9.9:53: i/o timeout
2025-11-05T00:05:21-08:00 ERRO shared/relay/client/dialer/quic/quic.go:56: failed to resolve UDP address: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:60277->9.9.9.9:53: i/o timeout
2025-11-05T00:05:21-08:00 ERRO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via quic: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:60277->9.9.9.9:53: i/o timeout
2025-11-05T00:05:22-08:00 INFO client/cmd/service_controller.go:100: stopped NetBird service
2025-11-05T00:07:22-08:00 INFO client/cmd/service_controller.go:27: starting NetBird service
2025-11-05T00:07:22-08:00 INFO client/cmd/service_controller.go:74: started daemon server: /var/run/netbird.sock
2025-11-05T00:07:22-08:00 INFO client/internal/connect.go:124: starting NetBird client version 0.59.11 on linux/amd64
2025-11-05T00:07:22-08:00 INFO client/net/env_linux.go:70: system supports advanced routing
2025-11-05T00:07:22-08:00 INFO client/internal/connect.go:265: connecting to the Relay service(s): rels://relay.netbird.io:443
2025-11-05T00:07:22-08:00 INFO shared/relay/client/picker.go:71: try to connecting to relay server: rels://relay.netbird.io:443
2025-11-05T00:07:22-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:168: create new relay connection: local peerID: R48lbpXc9oXQL+cRAL2/EMSd6HTtg70DyrJsrG3pmBM=, local peer hashedID: sha-wZTVe8xMHaw36fCmuWtSeeNTaSc17TAjBApRyAsQGOk=
2025-11-05T00:07:22-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:174: connecting to relay server
2025-11-05T00:07:22-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via quic
2025-11-05T00:07:22-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via WS
2025-11-05T00:07:22-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:91: successfully dialed via: WS
2025-11-05T00:07:22-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:77: connection attempt aborted via: quic
2025-11-05T00:07:22-08:00 INFO [relay: rels://streamline-us-sjo1-0.relay.netbird.io:443] shared/relay/client/client.go:196: relay connection established
2025-11-05T00:07:22-08:00 INFO shared/relay/client/picker.go:89: connected to Relay server: rels://relay.netbird.io:443
2025-11-05T00:07:22-08:00 INFO shared/relay/client/picker.go:63: chosen home Relay server: rels://relay.netbird.io:443
2025-11-05T00:07:22-08:00 INFO client/internal/engine.go:268: I am: R48lbpXc9oXQL+cRAL2/EMSd6HTtg70DyrJsrG3pmBM=
2025-11-05T00:07:23-08:00 INFO client/iface/wgproxy/ebpf/proxy.go:97: local wg proxy listening on: 3128
2025-11-05T00:07:23-08:00 INFO client/iface/wgproxy/factory_kernel.go:31: WireGuard Proxy Factory will produce eBPF proxy
2025-11-05T00:07:23-08:00 INFO client/internal/routemanager/manager.go:235: Routing setup complete
2025-11-05T00:07:23-08:00 INFO client/firewall/create_linux.go:70: creating an iptables firewall manager
2025-11-05T00:07:23-08:00 INFO client/internal/dns/host_unix.go:54: System DNS manager discovered: file
2025-11-05T00:07:23-08:00 INFO client/internal/conn_mgr.go:62: lazy connection manager is disabled
2025-11-05T00:07:33-08:00 WARN shared/signal/client/grpc.go:154: disconnected from the Signal Exchange due to an error: didn't receive a registration header from the Signal server whille connecting to the streams
2025-11-05T00:07:54-08:00 ERRO client/grpc/dialer_generic.go:39: Failed to dial: dial tcp: lookup signal.netbird.io: i/o timeout
2025-11-05T00:07:54-08:00 INFO ./caller_not_available:0: 2025/11/05 00:07:54 WARNING: [core] [Channel #6 SubChannel #7]grpc: addrConn.createTransport failed to connect to {Addr: "signal.netbird.io:443", ServerName: "signal.netbird.io:443", BalancerAttributes: {"<%!p(pickfirstleaf.managedByPickfirstKeyType={})>": "<%!p(bool=true)>" }}. Err: connection error: desc = "transport: Error while dialing: nbnet.NewDialer().DialContext: dial tcp: lookup signal.netbird.io: i/o timeout"
2025-11-05T00:07:57-08:00 ERRO [relay: rels://streamline-us-sjo1-0.relay.netbird.io:443] shared/relay/client/client.go:511: health check timeout
2025-11-05T00:07:57-08:00 INFO [relay: rels://streamline-us-sjo1-0.relay.netbird.io:443] shared/relay/client/client.go:370: start to Relay read loop exit
2025-11-05T00:07:57-08:00 INFO [relay: rels://streamline-us-sjo1-0.relay.netbird.io:443] shared/relay/client/client.go:597: closing all peer connections
2025-11-05T00:07:57-08:00 INFO [relay: rels://streamline-us-sjo1-0.relay.netbird.io:443] shared/relay/client/client.go:605: waiting for read loop to close
2025-11-05T00:07:57-08:00 INFO [relay: rels://streamline-us-sjo1-0.relay.netbird.io:443] shared/relay/client/client.go:607: relay connection closed
2025-11-05T00:07:59-08:00 INFO shared/relay/client/guard.go:82: try to reconnect to Relay server: rels://relay.netbird.io:443
2025-11-05T00:07:59-08:00 INFO [relay: rels://streamline-us-sjo1-0.relay.netbird.io:443] shared/relay/client/client.go:174: connecting to relay server
2025-11-05T00:07:59-08:00 INFO [relay: rels://streamline-us-sjo1-0.relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via quic
2025-11-05T00:07:59-08:00 INFO [relay: rels://streamline-us-sjo1-0.relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via WS
2025-11-05T00:08:15-08:00 ERRO client/grpc/dialer_generic.go:39: Failed to dial: dial tcp: lookup signal.netbird.io: i/o timeout
2025-11-05T00:08:15-08:00 INFO ./caller_not_available:0: 2025/11/05 00:08:15 WARNING: [core] [Channel #6 SubChannel #7]grpc: addrConn.createTransport failed to connect to {Addr: "signal.netbird.io:443", ServerName: "signal.netbird.io:443", BalancerAttributes: {"<%!p(pickfirstleaf.managedByPickfirstKeyType={})>": "<%!p(bool=true)>" }}. Err: connection error: desc = "transport: Error while dialing: nbnet.NewDialer().DialContext: dial tcp: lookup signal.netbird.io: i/o timeout"
2025-11-05T00:08:19-08:00 ERRO shared/relay/client/dialer/quic/quic.go:56: failed to resolve UDP address: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:36304->9.9.9.9:53: i/o timeout
2025-11-05T00:08:19-08:00 ERRO [relay: rels://streamline-us-sjo1-0.relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via quic: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:36304->9.9.9.9:53: i/o timeout
2025-11-05T00:08:19-08:00 ERRO shared/relay/client/dialer/ws/ws.go:48: failed to dial to Relay server 'wss://relay.netbird.io:443': failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:33151->9.9.9.9:53: i/o timeout
2025-11-05T00:08:19-08:00 ERRO [relay: rels://streamline-us-sjo1-0.relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via WS: failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:33151->9.9.9.9:53: i/o timeout
2025-11-05T00:08:19-08:00 ERRO shared/relay/client/guard.go:85: failed to reconnect to relay server: failed to dial to Relay server on any protocol
2025-11-05T00:08:19-08:00 INFO shared/relay/client/guard.go:92: try to pick up a new Relay server
2025-11-05T00:08:19-08:00 INFO shared/relay/client/picker.go:71: try to connecting to relay server: rels://relay.netbird.io:443
2025-11-05T00:08:19-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:168: create new relay connection: local peerID: R48lbpXc9oXQL+cRAL2/EMSd6HTtg70DyrJsrG3pmBM=, local peer hashedID: sha-wZTVe8xMHaw36fCmuWtSeeNTaSc17TAjBApRyAsQGOk=
2025-11-05T00:08:19-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:174: connecting to relay server
2025-11-05T00:08:19-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via quic
2025-11-05T00:08:19-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via WS
2025-11-05T00:08:26-08:00 INFO client/cmd/root.go:196: shutdown signal received
2025-11-05T00:08:26-08:00 ERRO shared/relay/client/guard.go:59: failed to pick new Relay server: failed to connect to any relay server: context canceled
2025-11-05T00:08:26-08:00 INFO shared/relay/client/guard.go:92: try to pick up a new Relay server
2025-11-05T00:08:26-08:00 WARN shared/signal/client/grpc.go:154: disconnected from the Signal Exchange due to an error: rpc error: code = Canceled desc = latest balancer error: connection error: desc = "transport: Error while dialing: nbnet.NewDialer().DialContext: dial tcp: lookup signal.netbird.io: i/o timeout"
2025-11-05T00:08:26-08:00 ERRO shared/signal/client/grpc.go:186: exiting the Signal service connection retry loop due to the unrecoverable error: context canceled
2025-11-05T00:08:26-08:00 INFO shared/relay/client/picker.go:71: try to connecting to relay server: rels://relay.netbird.io:443
2025-11-05T00:08:26-08:00 ERRO shared/relay/client/guard.go:59: failed to pick new Relay server: failed to connect to any relay server: context canceled
2025-11-05T00:08:26-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:168: create new relay connection: local peerID: R48lbpXc9oXQL+cRAL2/EMSd6HTtg70DyrJsrG3pmBM=, local peer hashedID: sha-wZTVe8xMHaw36fCmuWtSeeNTaSc17TAjBApRyAsQGOk=
2025-11-05T00:08:26-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:174: connecting to relay server
2025-11-05T00:08:26-08:00 INFO client/internal/engine.go:981: connecting to Management Service updates stream
2025-11-05T00:08:26-08:00 INFO client/internal/engine.go:1751: Network monitor is disabled, not starting
2025-11-05T00:08:26-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via quic
2025-11-05T00:08:26-08:00 INFO client/internal/connect.go:283: Netbird engine started, the IP is: 100.100.120.19/16
2025-11-05T00:08:26-08:00 INFO client/internal/engine.go:289: Network monitor: stopped
2025-11-05T00:08:26-08:00 ERRO client/internal/dns/server.go:346: failed to restore host DNS settings: restoring /etc/resolv.conf from /etc/resolv.conf.original.netbird: checking stats for /etc/resolv.conf.original.netbird file when copying it. Error: stat /etc/resolv.conf.original.netbird: no such file or directory
2025-11-05T00:08:26-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via WS
2025-11-05T00:08:26-08:00 INFO client/internal/wg_iface_monitor.go:50: Interface monitor: watching wt0 (index: 59)
2025-11-05T00:08:26-08:00 INFO client/internal/wg_iface_monitor.go:58: Interface monitor: stopped for wt0
2025-11-05T00:08:26-08:00 WARN client/internal/engine.go:495: WireGuard interface monitor: wg interface monitor stopped: context canceled
2025-11-05T00:08:26-08:00 INFO client/internal/routemanager/manager.go:305: Routing cleanup complete
2025-11-05T00:08:26-08:00 ERRO shared/management/client/grpc.go:278: failed while getting Management Service public key: rpc error: code = Canceled desc = context canceled
2025-11-05T00:08:26-08:00 WARN shared/management/client/grpc.go:137: exiting the Management service connection retry loop due to the unrecoverable error: context canceled
2025-11-05T00:08:26-08:00 ERRO client/iface/udpmux/universal.go:98: error while reading packet: shared socked stopped
2025-11-05T00:08:26-08:00 INFO client/iface/iface.go:309: interface wt0 has been removed
2025-11-05T00:08:26-08:00 INFO client/internal/engine.go:339: stopped Netbird Engine
2025-11-05T00:08:26-08:00 INFO client/server/server.go:830: service is down
2025-11-05T00:08:26-08:00 INFO client/internal/connect.go:305: stopped NetBird client
2025-11-05T00:08:26-08:00 ERRO client/grpc/dialer_generic.go:39: Failed to dial: dial tcp: lookup signal.netbird.io: operation was canceled
2025-11-05T00:08:26-08:00 INFO ./caller_not_available:0: 2025/11/05 00:08:26 WARNING: [core] [Channel #6 SubChannel #7]grpc: addrConn.createTransport failed to connect to {Addr: "signal.netbird.io:443", ServerName: "signal.netbird.io:443", BalancerAttributes: {"<%!p(pickfirstleaf.managedByPickfirstKeyType={})>": "<%!p(bool=true)>" }}. Err: connection error: desc = "transport: Error while dialing: nbnet.NewDialer().DialContext: dial tcp: lookup signal.netbird.io: operation was canceled"
2025-11-05T00:08:28-08:00 INFO client/cmd/service_controller.go:100: stopped NetBird service
2025-11-05T00:20:23-08:00 INFO client/cmd/service_controller.go:27: starting NetBird service
2025-11-05T00:20:23-08:00 INFO client/cmd/service_controller.go:74: started daemon server: /var/run/netbird.sock
2025-11-05T00:20:23-08:00 INFO client/internal/connect.go:124: starting NetBird client version 0.59.11 on linux/amd64
2025-11-05T00:20:23-08:00 INFO client/net/env_linux.go:70: system supports advanced routing
2025-11-05T00:20:24-08:00 INFO client/internal/connect.go:265: connecting to the Relay service(s): rels://relay.netbird.io:443
2025-11-05T00:20:24-08:00 INFO shared/relay/client/picker.go:71: try to connecting to relay server: rels://relay.netbird.io:443
2025-11-05T00:20:24-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:168: create new relay connection: local peerID: R48lbpXc9oXQL+cRAL2/EMSd6HTtg70DyrJsrG3pmBM=, local peer hashedID: sha-wZTVe8xMHaw36fCmuWtSeeNTaSc17TAjBApRyAsQGOk=
2025-11-05T00:20:24-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:174: connecting to relay server
2025-11-05T00:20:24-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via quic
2025-11-05T00:20:24-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via WS
2025-11-05T00:20:24-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:91: successfully dialed via: WS
2025-11-05T00:20:24-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:77: connection attempt aborted via: quic
2025-11-05T00:20:24-08:00 INFO [relay: rels://streamline-us-sjo1-1.relay.netbird.io:443] shared/relay/client/client.go:196: relay connection established
2025-11-05T00:20:24-08:00 INFO shared/relay/client/picker.go:89: connected to Relay server: rels://relay.netbird.io:443
2025-11-05T00:20:24-08:00 INFO shared/relay/client/picker.go:63: chosen home Relay server: rels://relay.netbird.io:443
2025-11-05T00:20:24-08:00 INFO client/internal/engine.go:268: I am: R48lbpXc9oXQL+cRAL2/EMSd6HTtg70DyrJsrG3pmBM=
2025-11-05T00:20:24-08:00 INFO client/iface/wgproxy/ebpf/proxy.go:97: local wg proxy listening on: 3128
2025-11-05T00:20:24-08:00 INFO client/iface/wgproxy/factory_kernel.go:31: WireGuard Proxy Factory will produce eBPF proxy
2025-11-05T00:20:24-08:00 INFO client/internal/routemanager/manager.go:235: Routing setup complete
2025-11-05T00:20:24-08:00 INFO client/firewall/create_linux.go:70: creating an iptables firewall manager
2025-11-05T00:20:24-08:00 INFO client/internal/dns/host_unix.go:54: System DNS manager discovered: file
2025-11-05T00:20:24-08:00 INFO client/internal/conn_mgr.go:62: lazy connection manager is disabled
2025-11-05T00:20:35-08:00 WARN shared/signal/client/grpc.go:154: disconnected from the Signal Exchange due to an error: didn't receive a registration header from the Signal server whille connecting to the streams
2025-11-05T00:20:55-08:00 ERRO client/grpc/dialer_generic.go:39: Failed to dial: dial tcp: lookup signal.netbird.io: i/o timeout
2025-11-05T00:20:55-08:00 INFO ./caller_not_available:0: 2025/11/05 00:20:55 WARNING: [core] [Channel #7 SubChannel #8]grpc: addrConn.createTransport failed to connect to {Addr: "signal.netbird.io:443", ServerName: "signal.netbird.io:443", BalancerAttributes: {"<%!p(pickfirstleaf.managedByPickfirstKeyType={})>": "<%!p(bool=true)>" }}. Err: connection error: desc = "transport: Error while dialing: nbnet.NewDialer().DialContext: dial tcp: lookup signal.netbird.io: i/o timeout"
2025-11-05T00:20:59-08:00 ERRO [relay: rels://streamline-us-sjo1-1.relay.netbird.io:443] shared/relay/client/client.go:511: health check timeout
2025-11-05T00:20:59-08:00 INFO [relay: rels://streamline-us-sjo1-1.relay.netbird.io:443] shared/relay/client/client.go:370: start to Relay read loop exit
2025-11-05T00:20:59-08:00 INFO [relay: rels://streamline-us-sjo1-1.relay.netbird.io:443] shared/relay/client/client.go:597: closing all peer connections
2025-11-05T00:20:59-08:00 INFO [relay: rels://streamline-us-sjo1-1.relay.netbird.io:443] shared/relay/client/client.go:605: waiting for read loop to close
2025-11-05T00:20:59-08:00 INFO [relay: rels://streamline-us-sjo1-1.relay.netbird.io:443] shared/relay/client/client.go:607: relay connection closed
2025-11-05T00:21:00-08:00 INFO shared/relay/client/guard.go:82: try to reconnect to Relay server: rels://relay.netbird.io:443
2025-11-05T00:21:00-08:00 INFO [relay: rels://streamline-us-sjo1-1.relay.netbird.io:443] shared/relay/client/client.go:174: connecting to relay server
2025-11-05T00:21:00-08:00 INFO [relay: rels://streamline-us-sjo1-1.relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via quic
2025-11-05T00:21:00-08:00 INFO [relay: rels://streamline-us-sjo1-1.relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via WS
2025-11-05T00:21:14-08:00 INFO client/cmd/root.go:196: shutdown signal received
2025-11-05T00:21:14-08:00 INFO client/internal/engine.go:981: connecting to Management Service updates stream
2025-11-05T00:21:14-08:00 INFO client/internal/engine.go:1751: Network monitor is disabled, not starting
2025-11-05T00:21:14-08:00 WARN shared/signal/client/grpc.go:154: disconnected from the Signal Exchange due to an error: rpc error: code = Canceled desc = latest balancer error: connection error: desc = "transport: Error while dialing: nbnet.NewDialer().DialContext: dial tcp: lookup signal.netbird.io: i/o timeout"
2025-11-05T00:21:14-08:00 INFO client/internal/connect.go:283: Netbird engine started, the IP is: 100.100.120.19/16
2025-11-05T00:21:14-08:00 ERRO shared/signal/client/grpc.go:186: exiting the Signal service connection retry loop due to the unrecoverable error: context canceled
2025-11-05T00:21:14-08:00 INFO client/internal/engine.go:289: Network monitor: stopped
2025-11-05T00:21:14-08:00 ERRO client/internal/dns/server.go:346: failed to restore host DNS settings: restoring /etc/resolv.conf from /etc/resolv.conf.original.netbird: checking stats for /etc/resolv.conf.original.netbird file when copying it. Error: stat /etc/resolv.conf.original.netbird: no such file or directory
2025-11-05T00:21:14-08:00 INFO client/internal/wg_iface_monitor.go:50: Interface monitor: watching wt0 (index: 60)
2025-11-05T00:21:14-08:00 INFO client/internal/wg_iface_monitor.go:58: Interface monitor: stopped for wt0
2025-11-05T00:21:14-08:00 WARN client/internal/engine.go:495: WireGuard interface monitor: wg interface monitor stopped: context canceled
2025-11-05T00:21:14-08:00 INFO client/internal/routemanager/manager.go:305: Routing cleanup complete
2025-11-05T00:21:14-08:00 ERRO shared/management/client/grpc.go:278: failed while getting Management Service public key: rpc error: code = Canceled desc = context canceled
2025-11-05T00:21:14-08:00 WARN shared/management/client/grpc.go:137: exiting the Management service connection retry loop due to the unrecoverable error: context canceled
2025-11-05T00:21:14-08:00 ERRO client/iface/udpmux/universal.go:98: error while reading packet: shared socked stopped
2025-11-05T00:21:14-08:00 INFO client/iface/iface.go:309: interface wt0 has been removed
2025-11-05T00:21:14-08:00 INFO client/internal/engine.go:339: stopped Netbird Engine
2025-11-05T00:21:14-08:00 INFO client/server/server.go:830: service is down
2025-11-05T00:21:14-08:00 INFO client/internal/connect.go:305: stopped NetBird client
2025-11-05T00:21:14-08:00 ERRO client/grpc/dialer_generic.go:39: Failed to dial: dial tcp: lookup signal.netbird.io: operation was canceled
2025-11-05T00:21:14-08:00 INFO ./caller_not_available:0: 2025/11/05 00:21:14 WARNING: [core] [Channel #7 SubChannel #8]grpc: addrConn.createTransport failed to connect to {Addr: "signal.netbird.io:443", ServerName: "signal.netbird.io:443", BalancerAttributes: {"<%!p(pickfirstleaf.managedByPickfirstKeyType={})>": "<%!p(bool=true)>" }}. Err: connection error: desc = "transport: Error while dialing: nbnet.NewDialer().DialContext: dial tcp: lookup signal.netbird.io: operation was canceled"
2025-11-05T00:21:15-08:00 ERRO shared/relay/client/dialer/quic/quic.go:56: failed to resolve UDP address: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:48195->9.9.9.9:53: i/o timeout
2025-11-05T00:21:15-08:00 ERRO [relay: rels://streamline-us-sjo1-1.relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via quic: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:48195->9.9.9.9:53: i/o timeout
2025-11-05T00:21:15-08:00 ERRO shared/relay/client/dialer/ws/ws.go:48: failed to dial to Relay server 'wss://relay.netbird.io:443': failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:40999->9.9.9.9:53: i/o timeout
2025-11-05T00:21:15-08:00 ERRO [relay: rels://streamline-us-sjo1-1.relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via WS: failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:40999->9.9.9.9:53: i/o timeout
2025-11-05T00:21:15-08:00 ERRO shared/relay/client/guard.go:85: failed to reconnect to relay server: failed to dial to Relay server on any protocol
2025-11-05T00:21:16-08:00 INFO client/cmd/service_controller.go:100: stopped NetBird service
2025-11-05T00:44:32-08:00 INFO client/cmd/service_controller.go:27: starting NetBird service
2025-11-05T00:44:32-08:00 INFO client/internal/statemanager/manager.go:412: cleaning up state iptables_state
2025-11-05T00:44:32-08:00 INFO client/cmd/service_controller.go:74: started daemon server: /var/run/netbird.sock
2025-11-05T00:44:32-08:00 INFO client/internal/connect.go:124: starting NetBird client version 0.59.11 on linux/amd64
2025-11-05T00:44:32-08:00 INFO client/net/env_linux.go:70: system supports advanced routing
2025-11-05T00:44:40-08:00 INFO client/cmd/root.go:196: shutdown signal received
2025-11-05T00:44:40-08:00 ERRO client/grpc/dialer_generic.go:39: Failed to dial: dial tcp: lookup api.netbird.io: operation was canceled
2025-11-05T00:44:40-08:00 INFO client/server/server.go:830: service is down
2025-11-05T00:44:40-08:00 INFO ./caller_not_available:0: 2025/11/05 00:44:40 WARNING: [core] [Channel #3 SubChannel #4]grpc: addrConn.createTransport failed to connect to {Addr: "api.netbird.io:443", ServerName: "api.netbird.io:443", BalancerAttributes: {"<%!p(pickfirstleaf.managedByPickfirstKeyType={})>": "<%!p(bool=true)>" }}. Err: connection error: desc = "transport: Error while dialing: nbnet.NewDialer().DialContext: dial tcp: lookup api.netbird.io: operation was canceled"
2025-11-05T00:44:40-08:00 INFO client/grpc/dialer.go:60: DialContext error: context canceled
2025-11-05T00:44:40-08:00 INFO shared/management/client/grpc.go:58: createConnection error: context canceled
2025-11-05T00:44:40-08:00 ERRO shared/management/client/grpc.go:66: failed creating connection to Management Service: context canceled
2025-11-05T00:44:42-08:00 INFO client/cmd/service_controller.go:100: stopped NetBird service
2025-11-05T00:48:11-08:00 INFO client/cmd/service_controller.go:27: starting NetBird service
2025-11-05T00:48:11-08:00 INFO client/cmd/service_controller.go:74: started daemon server: /var/run/netbird.sock
2025-11-05T00:48:11-08:00 INFO client/internal/connect.go:124: starting NetBird client version 0.59.11 on linux/amd64
2025-11-05T00:48:11-08:00 INFO client/net/env_linux.go:70: system supports advanced routing
2025-11-05T00:48:11-08:00 INFO client/internal/connect.go:265: connecting to the Relay service(s): rels://relay.netbird.io:443
2025-11-05T00:48:11-08:00 INFO shared/relay/client/picker.go:71: try to connecting to relay server: rels://relay.netbird.io:443
2025-11-05T00:48:11-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:168: create new relay connection: local peerID: R48lbpXc9oXQL+cRAL2/EMSd6HTtg70DyrJsrG3pmBM=, local peer hashedID: sha-wZTVe8xMHaw36fCmuWtSeeNTaSc17TAjBApRyAsQGOk=
2025-11-05T00:48:11-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:174: connecting to relay server
2025-11-05T00:48:11-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via quic
2025-11-05T00:48:11-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via WS
2025-11-05T00:48:11-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:91: successfully dialed via: WS
2025-11-05T00:48:11-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:77: connection attempt aborted via: quic
2025-11-05T00:48:12-08:00 INFO [relay: rels://streamline-us-sjo1-1.relay.netbird.io:443] shared/relay/client/client.go:196: relay connection established
2025-11-05T00:48:12-08:00 INFO shared/relay/client/picker.go:89: connected to Relay server: rels://relay.netbird.io:443
2025-11-05T00:48:12-08:00 INFO shared/relay/client/picker.go:63: chosen home Relay server: rels://relay.netbird.io:443
2025-11-05T00:48:12-08:00 INFO client/internal/engine.go:268: I am: R48lbpXc9oXQL+cRAL2/EMSd6HTtg70DyrJsrG3pmBM=
2025-11-05T00:48:12-08:00 INFO client/iface/wgproxy/ebpf/proxy.go:97: local wg proxy listening on: 3128
2025-11-05T00:48:12-08:00 INFO client/iface/wgproxy/factory_kernel.go:31: WireGuard Proxy Factory will produce eBPF proxy
2025-11-05T00:48:12-08:00 INFO client/internal/routemanager/manager.go:235: Routing setup complete
2025-11-05T00:48:12-08:00 INFO client/firewall/create_linux.go:70: creating an iptables firewall manager
2025-11-05T00:48:12-08:00 INFO client/internal/dns/host_unix.go:54: System DNS manager discovered: file
2025-11-05T00:48:12-08:00 INFO client/internal/conn_mgr.go:62: lazy connection manager is disabled
2025-11-05T00:48:22-08:00 WARN shared/signal/client/grpc.go:154: disconnected from the Signal Exchange due to an error: didn't receive a registration header from the Signal server whille connecting to the streams
2025-11-05T00:48:43-08:00 ERRO client/grpc/dialer_generic.go:39: Failed to dial: dial tcp: lookup signal.netbird.io: i/o timeout
2025-11-05T00:48:43-08:00 INFO ./caller_not_available:0: 2025/11/05 00:48:43 WARNING: [core] [Channel #6 SubChannel #7]grpc: addrConn.createTransport failed to connect to {Addr: "signal.netbird.io:443", ServerName: "signal.netbird.io:443", BalancerAttributes: {"<%!p(pickfirstleaf.managedByPickfirstKeyType={})>": "<%!p(bool=true)>" }}. Err: connection error: desc = "transport: Error while dialing: nbnet.NewDialer().DialContext: dial tcp: lookup signal.netbird.io: i/o timeout"
2025-11-05T00:48:47-08:00 ERRO [relay: rels://streamline-us-sjo1-1.relay.netbird.io:443] shared/relay/client/client.go:511: health check timeout
2025-11-05T00:48:47-08:00 INFO [relay: rels://streamline-us-sjo1-1.relay.netbird.io:443] shared/relay/client/client.go:370: start to Relay read loop exit
2025-11-05T00:48:47-08:00 INFO [relay: rels://streamline-us-sjo1-1.relay.netbird.io:443] shared/relay/client/client.go:597: closing all peer connections
2025-11-05T00:48:47-08:00 INFO [relay: rels://streamline-us-sjo1-1.relay.netbird.io:443] shared/relay/client/client.go:605: waiting for read loop to close
2025-11-05T00:48:47-08:00 INFO [relay: rels://streamline-us-sjo1-1.relay.netbird.io:443] shared/relay/client/client.go:607: relay connection closed
2025-11-05T00:48:48-08:00 INFO shared/relay/client/guard.go:82: try to reconnect to Relay server: rels://relay.netbird.io:443
2025-11-05T00:48:48-08:00 INFO [relay: rels://streamline-us-sjo1-1.relay.netbird.io:443] shared/relay/client/client.go:174: connecting to relay server
2025-11-05T00:48:48-08:00 INFO [relay: rels://streamline-us-sjo1-1.relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via quic
2025-11-05T00:48:48-08:00 INFO [relay: rels://streamline-us-sjo1-1.relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via WS
2025-11-05T00:49:04-08:00 ERRO client/grpc/dialer_generic.go:39: Failed to dial: dial tcp: lookup signal.netbird.io: i/o timeout
2025-11-05T00:49:04-08:00 INFO ./caller_not_available:0: 2025/11/05 00:49:04 WARNING: [core] [Channel #6 SubChannel #7]grpc: addrConn.createTransport failed to connect to {Addr: "signal.netbird.io:443", ServerName: "signal.netbird.io:443", BalancerAttributes: {"<%!p(pickfirstleaf.managedByPickfirstKeyType={})>": "<%!p(bool=true)>" }}. Err: connection error: desc = "transport: Error while dialing: nbnet.NewDialer().DialContext: dial tcp: lookup signal.netbird.io: i/o timeout"
2025-11-05T00:49:08-08:00 ERRO shared/relay/client/dialer/quic/quic.go:56: failed to resolve UDP address: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:48075->9.9.9.9:53: i/o timeout
2025-11-05T00:49:08-08:00 ERRO [relay: rels://streamline-us-sjo1-1.relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via quic: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:48075->9.9.9.9:53: i/o timeout
2025-11-05T00:49:08-08:00 ERRO shared/relay/client/dialer/ws/ws.go:48: failed to dial to Relay server 'wss://relay.netbird.io:443': failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:56784->9.9.9.9:53: i/o timeout
2025-11-05T00:49:08-08:00 ERRO [relay: rels://streamline-us-sjo1-1.relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via WS: failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:56784->9.9.9.9:53: i/o timeout
2025-11-05T00:49:08-08:00 ERRO shared/relay/client/guard.go:85: failed to reconnect to relay server: failed to dial to Relay server on any protocol
2025-11-05T00:49:08-08:00 INFO shared/relay/client/guard.go:92: try to pick up a new Relay server
2025-11-05T00:49:08-08:00 INFO shared/relay/client/picker.go:71: try to connecting to relay server: rels://relay.netbird.io:443
2025-11-05T00:49:08-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:168: create new relay connection: local peerID: R48lbpXc9oXQL+cRAL2/EMSd6HTtg70DyrJsrG3pmBM=, local peer hashedID: sha-wZTVe8xMHaw36fCmuWtSeeNTaSc17TAjBApRyAsQGOk=
2025-11-05T00:49:08-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:174: connecting to relay server
2025-11-05T00:49:08-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via quic
2025-11-05T00:49:08-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via WS
2025-11-05T00:49:26-08:00 ERRO client/grpc/dialer_generic.go:39: Failed to dial: dial tcp: lookup signal.netbird.io: i/o timeout
2025-11-05T00:49:26-08:00 INFO ./caller_not_available:0: 2025/11/05 00:49:26 WARNING: [core] [Channel #6 SubChannel #7]grpc: addrConn.createTransport failed to connect to {Addr: "signal.netbird.io:443", ServerName: "signal.netbird.io:443", BalancerAttributes: {"<%!p(pickfirstleaf.managedByPickfirstKeyType={})>": "<%!p(bool=true)>" }}. Err: connection error: desc = "transport: Error while dialing: nbnet.NewDialer().DialContext: dial tcp: lookup signal.netbird.io: i/o timeout"
2025-11-05T00:49:28-08:00 ERRO shared/relay/client/dialer/quic/quic.go:56: failed to resolve UDP address: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:54302->9.9.9.9:53: i/o timeout
2025-11-05T00:49:28-08:00 ERRO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via quic: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:54302->9.9.9.9:53: i/o timeout
2025-11-05T00:49:28-08:00 ERRO shared/relay/client/dialer/ws/ws.go:48: failed to dial to Relay server 'wss://relay.netbird.io:443': failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:36118->9.9.9.9:53: i/o timeout
2025-11-05T00:49:28-08:00 ERRO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via WS: failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:36118->9.9.9.9:53: i/o timeout
2025-11-05T00:49:28-08:00 ERRO shared/relay/client/guard.go:59: failed to pick new Relay server: failed to connect to any relay server: all attempts failed
2025-11-05T00:49:28-08:00 INFO shared/relay/client/guard.go:92: try to pick up a new Relay server
2025-11-05T00:49:28-08:00 INFO shared/relay/client/picker.go:71: try to connecting to relay server: rels://relay.netbird.io:443
2025-11-05T00:49:28-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:168: create new relay connection: local peerID: R48lbpXc9oXQL+cRAL2/EMSd6HTtg70DyrJsrG3pmBM=, local peer hashedID: sha-wZTVe8xMHaw36fCmuWtSeeNTaSc17TAjBApRyAsQGOk=
2025-11-05T00:49:28-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:174: connecting to relay server
2025-11-05T00:49:28-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via quic
2025-11-05T00:49:28-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via WS
2025-11-05T00:49:48-08:00 ERRO shared/relay/client/dialer/quic/quic.go:56: failed to resolve UDP address: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:57042->9.9.9.9:53: i/o timeout
2025-11-05T00:49:48-08:00 ERRO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via quic: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:57042->9.9.9.9:53: i/o timeout
2025-11-05T00:49:48-08:00 ERRO shared/relay/client/dialer/ws/ws.go:48: failed to dial to Relay server 'wss://relay.netbird.io:443': failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:59021->9.9.9.9:53: i/o timeout
2025-11-05T00:49:48-08:00 ERRO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via WS: failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:59021->9.9.9.9:53: i/o timeout
2025-11-05T00:49:48-08:00 ERRO shared/relay/client/guard.go:59: failed to pick new Relay server: failed to connect to any relay server: all attempts failed
2025-11-05T00:49:48-08:00 INFO shared/relay/client/guard.go:92: try to pick up a new Relay server
2025-11-05T00:49:48-08:00 INFO shared/relay/client/picker.go:71: try to connecting to relay server: rels://relay.netbird.io:443
2025-11-05T00:49:48-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:168: create new relay connection: local peerID: R48lbpXc9oXQL+cRAL2/EMSd6HTtg70DyrJsrG3pmBM=, local peer hashedID: sha-wZTVe8xMHaw36fCmuWtSeeNTaSc17TAjBApRyAsQGOk=
2025-11-05T00:49:48-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:174: connecting to relay server
2025-11-05T00:49:48-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via quic
2025-11-05T00:49:48-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via WS
2025-11-05T00:49:48-08:00 ERRO client/grpc/dialer_generic.go:39: Failed to dial: dial tcp: lookup signal.netbird.io: i/o timeout
2025-11-05T00:49:48-08:00 INFO ./caller_not_available:0: 2025/11/05 00:49:48 WARNING: [core] [Channel #6 SubChannel #7]grpc: addrConn.createTransport failed to connect to {Addr: "signal.netbird.io:443", ServerName: "signal.netbird.io:443", BalancerAttributes: {"<%!p(pickfirstleaf.managedByPickfirstKeyType={})>": "<%!p(bool=true)>" }}. Err: connection error: desc = "transport: Error while dialing: nbnet.NewDialer().DialContext: dial tcp: lookup signal.netbird.io: i/o timeout"
2025-11-05T00:50:08-08:00 ERRO shared/relay/client/dialer/quic/quic.go:56: failed to resolve UDP address: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:53639->9.9.9.9:53: i/o timeout
2025-11-05T00:50:08-08:00 ERRO shared/relay/client/dialer/ws/ws.go:48: failed to dial to Relay server 'wss://relay.netbird.io:443': failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:46972->9.9.9.9:53: i/o timeout
2025-11-05T00:50:08-08:00 ERRO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via quic: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:53639->9.9.9.9:53: i/o timeout
2025-11-05T00:50:08-08:00 ERRO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via WS: failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:46972->9.9.9.9:53: i/o timeout
2025-11-05T00:50:08-08:00 ERRO shared/relay/client/guard.go:59: failed to pick new Relay server: failed to connect to any relay server: all attempts failed
2025-11-05T00:50:08-08:00 INFO shared/relay/client/guard.go:92: try to pick up a new Relay server
2025-11-05T00:50:08-08:00 INFO shared/relay/client/picker.go:71: try to connecting to relay server: rels://relay.netbird.io:443
2025-11-05T00:50:08-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:168: create new relay connection: local peerID: R48lbpXc9oXQL+cRAL2/EMSd6HTtg70DyrJsrG3pmBM=, local peer hashedID: sha-wZTVe8xMHaw36fCmuWtSeeNTaSc17TAjBApRyAsQGOk=
2025-11-05T00:50:08-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:174: connecting to relay server
2025-11-05T00:50:08-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via quic
2025-11-05T00:50:08-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via WS
2025-11-05T00:50:13-08:00 ERRO client/grpc/dialer_generic.go:39: Failed to dial: dial tcp: lookup signal.netbird.io: i/o timeout
2025-11-05T00:50:13-08:00 INFO ./caller_not_available:0: 2025/11/05 00:50:13 WARNING: [core] [Channel #6 SubChannel #7]grpc: addrConn.createTransport failed to connect to {Addr: "signal.netbird.io:443", ServerName: "signal.netbird.io:443", BalancerAttributes: {"<%!p(pickfirstleaf.managedByPickfirstKeyType={})>": "<%!p(bool=true)>" }}. Err: connection error: desc = "transport: Error while dialing: nbnet.NewDialer().DialContext: dial tcp: lookup signal.netbird.io: i/o timeout"
2025-11-05T00:50:28-08:00 ERRO shared/relay/client/dialer/quic/quic.go:56: failed to resolve UDP address: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:37560->9.9.9.9:53: i/o timeout
2025-11-05T00:50:28-08:00 ERRO shared/relay/client/dialer/ws/ws.go:48: failed to dial to Relay server 'wss://relay.netbird.io:443': failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:51098->9.9.9.9:53: i/o timeout
2025-11-05T00:50:28-08:00 ERRO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via quic: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:37560->9.9.9.9:53: i/o timeout
2025-11-05T00:50:28-08:00 ERRO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via WS: failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:51098->9.9.9.9:53: i/o timeout
2025-11-05T00:50:28-08:00 ERRO shared/relay/client/guard.go:59: failed to pick new Relay server: failed to connect to any relay server: all attempts failed
2025-11-05T00:50:28-08:00 INFO shared/relay/client/guard.go:92: try to pick up a new Relay server
2025-11-05T00:50:28-08:00 INFO shared/relay/client/picker.go:71: try to connecting to relay server: rels://relay.netbird.io:443
2025-11-05T00:50:28-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:168: create new relay connection: local peerID: R48lbpXc9oXQL+cRAL2/EMSd6HTtg70DyrJsrG3pmBM=, local peer hashedID: sha-wZTVe8xMHaw36fCmuWtSeeNTaSc17TAjBApRyAsQGOk=
2025-11-05T00:50:28-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:174: connecting to relay server
2025-11-05T00:50:28-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via quic
2025-11-05T00:50:28-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via WS
2025-11-05T00:50:38-08:00 ERRO client/grpc/dialer_generic.go:39: Failed to dial: dial tcp: lookup signal.netbird.io: i/o timeout
2025-11-05T00:50:38-08:00 INFO ./caller_not_available:0: 2025/11/05 00:50:38 WARNING: [core] [Channel #6 SubChannel #7]grpc: addrConn.createTransport failed to connect to {Addr: "signal.netbird.io:443", ServerName: "signal.netbird.io:443", BalancerAttributes: {"<%!p(pickfirstleaf.managedByPickfirstKeyType={})>": "<%!p(bool=true)>" }}. Err: connection error: desc = "transport: Error while dialing: nbnet.NewDialer().DialContext: dial tcp: lookup signal.netbird.io: i/o timeout"
2025-11-05T00:50:48-08:00 ERRO shared/relay/client/dialer/quic/quic.go:56: failed to resolve UDP address: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:38466->9.9.9.9:53: i/o timeout
2025-11-05T00:50:48-08:00 ERRO shared/relay/client/dialer/ws/ws.go:48: failed to dial to Relay server 'wss://relay.netbird.io:443': failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:49770->9.9.9.9:53: i/o timeout
2025-11-05T00:50:48-08:00 ERRO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via quic: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:38466->9.9.9.9:53: i/o timeout
2025-11-05T00:50:48-08:00 ERRO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via WS: failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:49770->9.9.9.9:53: i/o timeout
2025-11-05T00:50:48-08:00 ERRO shared/relay/client/guard.go:59: failed to pick new Relay server: failed to connect to any relay server: all attempts failed
2025-11-05T00:51:00-08:00 INFO shared/relay/client/guard.go:92: try to pick up a new Relay server
2025-11-05T00:51:00-08:00 INFO shared/relay/client/picker.go:71: try to connecting to relay server: rels://relay.netbird.io:443
2025-11-05T00:51:00-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:168: create new relay connection: local peerID: R48lbpXc9oXQL+cRAL2/EMSd6HTtg70DyrJsrG3pmBM=, local peer hashedID: sha-wZTVe8xMHaw36fCmuWtSeeNTaSc17TAjBApRyAsQGOk=
2025-11-05T00:51:00-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:174: connecting to relay server
2025-11-05T00:51:00-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via WS
2025-11-05T00:51:00-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via quic
2025-11-05T00:51:10-08:00 ERRO client/grpc/dialer_generic.go:39: Failed to dial: dial tcp: lookup signal.netbird.io: i/o timeout
2025-11-05T00:51:10-08:00 INFO ./caller_not_available:0: 2025/11/05 00:51:10 WARNING: [core] [Channel #6 SubChannel #7]grpc: addrConn.createTransport failed to connect to {Addr: "signal.netbird.io:443", ServerName: "signal.netbird.io:443", BalancerAttributes: {"<%!p(pickfirstleaf.managedByPickfirstKeyType={})>": "<%!p(bool=true)>" }}. Err: connection error: desc = "transport: Error while dialing: nbnet.NewDialer().DialContext: dial tcp: lookup signal.netbird.io: i/o timeout"
2025-11-05T00:51:20-08:00 ERRO shared/relay/client/dialer/quic/quic.go:56: failed to resolve UDP address: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:46377->9.9.9.9:53: i/o timeout
2025-11-05T00:51:20-08:00 ERRO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via quic: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:46377->9.9.9.9:53: i/o timeout
2025-11-05T00:51:20-08:00 ERRO shared/relay/client/dialer/ws/ws.go:48: failed to dial to Relay server 'wss://relay.netbird.io:443': failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:47597->9.9.9.9:53: i/o timeout
2025-11-05T00:51:20-08:00 ERRO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via WS: failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:47597->9.9.9.9:53: i/o timeout
2025-11-05T00:51:20-08:00 ERRO shared/relay/client/guard.go:59: failed to pick new Relay server: failed to connect to any relay server: all attempts failed
2025-11-05T00:51:43-08:00 ERRO client/grpc/dialer_generic.go:39: Failed to dial: dial tcp: lookup signal.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:42320->9.9.9.9:53: i/o timeout
2025-11-05T00:51:43-08:00 INFO ./caller_not_available:0: 2025/11/05 00:51:43 WARNING: [core] [Channel #6 SubChannel #7]grpc: addrConn.createTransport failed to connect to {Addr: "signal.netbird.io:443", ServerName: "signal.netbird.io:443", BalancerAttributes: {"<%!p(pickfirstleaf.managedByPickfirstKeyType={})>": "<%!p(bool=true)>" }}. Err: connection error: desc = "transport: Error while dialing: nbnet.NewDialer().DialContext: dial tcp: lookup signal.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:42320->9.9.9.9:53: i/o timeout"
2025-11-05T00:52:00-08:00 INFO shared/relay/client/guard.go:92: try to pick up a new Relay server
2025-11-05T00:52:00-08:00 INFO shared/relay/client/picker.go:71: try to connecting to relay server: rels://relay.netbird.io:443
2025-11-05T00:52:00-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:168: create new relay connection: local peerID: R48lbpXc9oXQL+cRAL2/EMSd6HTtg70DyrJsrG3pmBM=, local peer hashedID: sha-wZTVe8xMHaw36fCmuWtSeeNTaSc17TAjBApRyAsQGOk=
2025-11-05T00:52:00-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:174: connecting to relay server
2025-11-05T00:52:00-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via quic
2025-11-05T00:52:00-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via WS
2025-11-05T00:52:20-08:00 ERRO shared/relay/client/dialer/ws/ws.go:48: failed to dial to Relay server 'wss://relay.netbird.io:443': failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:58921->9.9.9.9:53: i/o timeout
2025-11-05T00:52:20-08:00 ERRO shared/relay/client/dialer/quic/quic.go:56: failed to resolve UDP address: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:43121->9.9.9.9:53: i/o timeout
2025-11-05T00:52:20-08:00 ERRO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via WS: failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:58921->9.9.9.9:53: i/o timeout
2025-11-05T00:52:20-08:00 ERRO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via quic: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:43121->9.9.9.9:53: i/o timeout
2025-11-05T00:52:20-08:00 ERRO shared/relay/client/guard.go:59: failed to pick new Relay server: failed to connect to any relay server: all attempts failed
2025-11-05T00:52:35-08:00 ERRO client/grpc/dialer_generic.go:39: Failed to dial: dial tcp: lookup signal.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:59685->9.9.9.9:53: i/o timeout
2025-11-05T00:52:35-08:00 INFO ./caller_not_available:0: 2025/11/05 00:52:35 WARNING: [core] [Channel #6 SubChannel #7]grpc: addrConn.createTransport failed to connect to {Addr: "signal.netbird.io:443", ServerName: "signal.netbird.io:443", BalancerAttributes: {"<%!p(pickfirstleaf.managedByPickfirstKeyType={})>": "<%!p(bool=true)>" }}. Err: connection error: desc = "transport: Error while dialing: nbnet.NewDialer().DialContext: dial tcp: lookup signal.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:59685->9.9.9.9:53: i/o timeout"
2025-11-05T00:53:00-08:00 INFO shared/relay/client/guard.go:92: try to pick up a new Relay server
2025-11-05T00:53:00-08:00 INFO shared/relay/client/picker.go:71: try to connecting to relay server: rels://relay.netbird.io:443
2025-11-05T00:53:00-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:168: create new relay connection: local peerID: R48lbpXc9oXQL+cRAL2/EMSd6HTtg70DyrJsrG3pmBM=, local peer hashedID: sha-wZTVe8xMHaw36fCmuWtSeeNTaSc17TAjBApRyAsQGOk=
2025-11-05T00:53:00-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:174: connecting to relay server
2025-11-05T00:53:00-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via WS
2025-11-05T00:53:00-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via quic
2025-11-05T00:53:20-08:00 ERRO shared/relay/client/dialer/quic/quic.go:56: failed to resolve UDP address: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:36204->9.9.9.9:53: i/o timeout
2025-11-05T00:53:20-08:00 ERRO shared/relay/client/dialer/ws/ws.go:48: failed to dial to Relay server 'wss://relay.netbird.io:443': failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:59617->9.9.9.9:53: i/o timeout
2025-11-05T00:53:20-08:00 ERRO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via quic: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:36204->9.9.9.9:53: i/o timeout
2025-11-05T00:53:20-08:00 ERRO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via WS: failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:59617->9.9.9.9:53: i/o timeout
2025-11-05T00:53:20-08:00 ERRO shared/relay/client/guard.go:59: failed to pick new Relay server: failed to connect to any relay server: all attempts failed
2025-11-05T00:53:36-08:00 ERRO client/grpc/dialer_generic.go:39: Failed to dial: dial tcp: lookup signal.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:32778->9.9.9.9:53: i/o timeout
2025-11-05T00:53:36-08:00 INFO ./caller_not_available:0: 2025/11/05 00:53:36 WARNING: [core] [Channel #6 SubChannel #7]grpc: addrConn.createTransport failed to connect to {Addr: "signal.netbird.io:443", ServerName: "signal.netbird.io:443", BalancerAttributes: {"<%!p(pickfirstleaf.managedByPickfirstKeyType={})>": "<%!p(bool=true)>" }}. Err: connection error: desc = "transport: Error while dialing: nbnet.NewDialer().DialContext: dial tcp: lookup signal.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:32778->9.9.9.9:53: i/o timeout"
2025-11-05T00:54:00-08:00 INFO shared/relay/client/guard.go:92: try to pick up a new Relay server
2025-11-05T00:54:00-08:00 INFO shared/relay/client/picker.go:71: try to connecting to relay server: rels://relay.netbird.io:443
2025-11-05T00:54:00-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:168: create new relay connection: local peerID: R48lbpXc9oXQL+cRAL2/EMSd6HTtg70DyrJsrG3pmBM=, local peer hashedID: sha-wZTVe8xMHaw36fCmuWtSeeNTaSc17TAjBApRyAsQGOk=
2025-11-05T00:54:00-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:174: connecting to relay server
2025-11-05T00:54:00-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via quic
2025-11-05T00:54:00-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via WS
2025-11-05T00:54:20-08:00 ERRO shared/relay/client/dialer/quic/quic.go:56: failed to resolve UDP address: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:42127->9.9.9.9:53: i/o timeout
2025-11-05T00:54:20-08:00 ERRO shared/relay/client/dialer/ws/ws.go:48: failed to dial to Relay server 'wss://relay.netbird.io:443': failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:43013->9.9.9.9:53: i/o timeout
2025-11-05T00:54:20-08:00 ERRO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via quic: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:42127->9.9.9.9:53: i/o timeout
2025-11-05T00:54:20-08:00 ERRO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via WS: failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:43013->9.9.9.9:53: i/o timeout
2025-11-05T00:54:20-08:00 ERRO shared/relay/client/guard.go:59: failed to pick new Relay server: failed to connect to any relay server: all attempts failed
2025-11-05T00:55:00-08:00 INFO shared/relay/client/guard.go:92: try to pick up a new Relay server
2025-11-05T00:55:00-08:00 INFO shared/relay/client/picker.go:71: try to connecting to relay server: rels://relay.netbird.io:443
2025-11-05T00:55:00-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:168: create new relay connection: local peerID: R48lbpXc9oXQL+cRAL2/EMSd6HTtg70DyrJsrG3pmBM=, local peer hashedID: sha-wZTVe8xMHaw36fCmuWtSeeNTaSc17TAjBApRyAsQGOk=
2025-11-05T00:55:00-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:174: connecting to relay server
2025-11-05T00:55:00-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via quic
2025-11-05T00:55:00-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via WS
2025-11-05T00:55:04-08:00 ERRO client/grpc/dialer_generic.go:39: Failed to dial: dial tcp: lookup signal.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:42085->9.9.9.9:53: i/o timeout
2025-11-05T00:55:04-08:00 INFO ./caller_not_available:0: 2025/11/05 00:55:04 WARNING: [core] [Channel #6 SubChannel #7]grpc: addrConn.createTransport failed to connect to {Addr: "signal.netbird.io:443", ServerName: "signal.netbird.io:443", BalancerAttributes: {"<%!p(pickfirstleaf.managedByPickfirstKeyType={})>": "<%!p(bool=true)>" }}. Err: connection error: desc = "transport: Error while dialing: nbnet.NewDialer().DialContext: dial tcp: lookup signal.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:42085->9.9.9.9:53: i/o timeout"
2025-11-05T00:55:20-08:00 ERRO shared/relay/client/dialer/quic/quic.go:56: failed to resolve UDP address: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:46867->9.9.9.9:53: i/o timeout
2025-11-05T00:55:20-08:00 ERRO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via quic: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:46867->9.9.9.9:53: i/o timeout
2025-11-05T00:55:20-08:00 ERRO shared/relay/client/dialer/ws/ws.go:48: failed to dial to Relay server 'wss://relay.netbird.io:443': failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:53173->9.9.9.9:53: i/o timeout
2025-11-05T00:55:20-08:00 ERRO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via WS: failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:53173->9.9.9.9:53: i/o timeout
2025-11-05T00:55:20-08:00 ERRO shared/relay/client/guard.go:59: failed to pick new Relay server: failed to connect to any relay server: all attempts failed
2025-11-05T00:56:00-08:00 INFO shared/relay/client/guard.go:92: try to pick up a new Relay server
2025-11-05T00:56:00-08:00 INFO shared/relay/client/picker.go:71: try to connecting to relay server: rels://relay.netbird.io:443
2025-11-05T00:56:00-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:168: create new relay connection: local peerID: R48lbpXc9oXQL+cRAL2/EMSd6HTtg70DyrJsrG3pmBM=, local peer hashedID: sha-wZTVe8xMHaw36fCmuWtSeeNTaSc17TAjBApRyAsQGOk=
2025-11-05T00:56:00-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/client.go:174: connecting to relay server
2025-11-05T00:56:00-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via quic
2025-11-05T00:56:00-08:00 INFO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:66: dialing Relay server via WS
2025-11-05T00:56:20-08:00 ERRO shared/relay/client/dialer/quic/quic.go:56: failed to resolve UDP address: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:56309->9.9.9.9:53: i/o timeout
2025-11-05T00:56:20-08:00 ERRO shared/relay/client/dialer/ws/ws.go:48: failed to dial to Relay server 'wss://relay.netbird.io:443': failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:54325->9.9.9.9:53: i/o timeout
2025-11-05T00:56:20-08:00 ERRO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via quic: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:56309->9.9.9.9:53: i/o timeout
2025-11-05T00:56:20-08:00 ERRO [relay: rels://relay.netbird.io:443] shared/relay/client/dialer/race_dialer.go:79: failed to dial via WS: failed to WebSocket dial: failed to send handshake request: Get "https://relay.netbird.io:443/relay": dial tcp: lookup relay.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:54325->9.9.9.9:53: i/o timeout
2025-11-05T00:56:20-08:00 ERRO shared/relay/client/guard.go:59: failed to pick new Relay server: failed to connect to any relay server: all attempts failed
2025-11-05T00:56:37-08:00 WARN shared/signal/client/grpc.go:154: disconnected from the Signal Exchange due to an error: rpc error: code = Canceled desc = latest balancer error: connection error: desc = "transport: Error while dialing: nbnet.NewDialer().DialContext: dial tcp: lookup signal.netbird.io on 9.9.9.9:53: read udp 172.16.10.23:42085->9.9.9.9:53: i/o timeout"
2025-11-05T00:56:37-08:00 ERRO shared/signal/client/grpc.go:186: exiting the Signal service connection retry loop due to the unrecoverable error: context canceled
2025-11-05T00:56:37-08:00 INFO client/cmd/root.go:196: shutdown signal received
2025-11-05T00:56:37-08:00 INFO client/internal/engine.go:981: connecting to Management Service updates stream
2025-11-05T00:56:37-08:00 INFO client/internal/engine.go:1751: Network monitor is disabled, not starting
2025-11-05T00:56:37-08:00 INFO client/internal/connect.go:283: Netbird engine started, the IP is: 100.100.120.19/16
2025-11-05T00:56:37-08:00 INFO client/internal/engine.go:289: Network monitor: stopped
2025-11-05T00:56:37-08:00 ERRO client/internal/dns/server.go:346: failed to restore host DNS settings: restoring /etc/resolv.conf from /etc/resolv.conf.original.netbird: checking stats for /etc/resolv.conf.original.netbird file when copying it. Error: stat /etc/resolv.conf.original.netbird: no such file or directory
2025-11-05T00:56:37-08:00 INFO client/internal/wg_iface_monitor.go:50: Interface monitor: watching wt0 (index: 47)
2025-11-05T00:56:37-08:00 INFO client/internal/wg_iface_monitor.go:58: Interface monitor: stopped for wt0
2025-11-05T00:56:37-08:00 WARN client/internal/engine.go:495: WireGuard interface monitor: wg interface monitor stopped: context canceled
2025-11-05T00:56:37-08:00 INFO client/internal/routemanager/manager.go:305: Routing cleanup complete
2025-11-05T00:56:37-08:00 ERRO shared/management/client/grpc.go:278: failed while getting Management Service public key: rpc error: code = Canceled desc = context canceled
2025-11-05T00:56:37-08:00 WARN shared/management/client/grpc.go:137: exiting the Management service connection retry loop due to the unrecoverable error: context canceled
2025-11-05T00:56:38-08:00 ERRO client/iface/udpmux/universal.go:98: error while reading packet: shared socked stopped
2025-11-05T00:56:38-08:00 INFO client/iface/iface.go:309: interface wt0 has been removed
2025-11-05T00:56:38-08:00 WARN client/internal/engine.go:1507: failed to reset firewall: 1 error occurred:
	* reset router: 1 error occurred:
	* clean jump rules: delete rule from chain POSTROUTING in table nat, err: running [/usr/sbin/iptables -t nat -C POSTROUTING -j NETBIRD-RT-NAT --wait]: exit status 2: iptables v1.8.11 (legacy): Couldn't load target `NETBIRD-RT-NAT':No such file or directory

Try `iptables -h' or 'iptables --help' for more information.

2025-11-05T00:56:38-08:00 INFO client/internal/engine.go:339: stopped Netbird Engine
2025-11-05T00:56:38-08:00 INFO client/server/server.go:830: service is down
2025-11-05T00:56:38-08:00 INFO client/internal/connect.go:305: stopped NetBird client
2025-11-05T00:56:40-08:00 INFO client/cmd/service_controller.go:100: stopped NetBird service
