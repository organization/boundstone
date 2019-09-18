module bstone

struct SessionManager {
mut:
    server VRakLib

    socket UdpSocket
    sessions map[string]Session
    session_by_address map[string]Session

    shutdown bool

    start_time_ms int

    port_checking bool

    next_session_id int
}

fn new_session_manager(server VRakLib, socket UdpSocket) &SessionManager {
    sm := &SessionManager {
        server: server
        socket: socket
        start_time_ms: 0 // TODO
    }
    return sm
}

fn (s SessionManager) get_raknet_time_ms() i64 {
    return 0 - s.start_time_ms // TODO
}

fn (s mut SessionManager) run() {
    for {
        if !s.shutdown {
            s.receive_packet()
        }

        for i, session in s.sessions {
            s.sessions[i].update()
        }
    }
}

fn (s mut SessionManager) receive_packet() {
    packet := s.socket.receive() or { return }
    pid := packet.buffer.buffer[0]

    if s.session_exists(packet.address) {
        mut session := s.get_session_by_address(packet.address)

        if (pid & BitflagValid) != 0 {
            if (pid & BitflagAck) != 0 {
                // ACK
                println('ack')
            } else if (pid & BitflagNak) != 0 {
                // NACK
                println('nack')
            } else {
                datagram := Datagram { p: new_packet_from_packet(packet) }
                session.handle_packet(datagram)
            }
        }
    } else {
        if pid == IdUnConnectedPong || pid == IdUnConnectedPong2 {
            mut ping := UnConnectedPingPacket { p: new_packet_from_packet(packet) }
            ping.decode()

            title := 'MCPE;Minecraft V Server!;361;1.12.0;0;100;123456789;Test;Survival;'
            len := 35 + title.len
            mut pong := UnConnectedPongPacket {
                p: new_packet([byte(0)].repeat(len).data, u32(len))
                server_id: 123456789
                ping_id: ping.ping_id
                str: title
            }
            pong.encode()
            pong.p.address = ping.p.address

            s.socket.send(pong, pong.p)
        } else if pid == IdOpenConnectionRequest1 {
            mut request := Request1Packet { p: new_packet_from_packet(packet) }
            request.decode()
            
            if request.version != 9 {
                mut incompatible := IncompatibleProtocolVersionPacket {
                    p: new_packet([byte(0)].repeat(26).data, u32(26))
                    version: 9
                    server_id: 123456789
                }
                incompatible.encode()
                incompatible.p.address = request.p.address

                s.socket.send(incompatible, incompatible.p)
                return
            }

            mut reply := Reply1Packet {
                p: new_packet([byte(0)].repeat(28).data, u32(28))
                security: true
                server_id: 123456789
                mtu_size: request.mtu_size
            }
            reply.encode()
            reply.p.address = request.p.address

            s.socket.send(reply, reply.p)
        } else if pid == IdOpenConnectionRequest2 {
            mut request := Request2Packet { p: new_packet_from_packet(packet) }
            request.decode()

            mut reply := Reply2Packet {
                p: new_packet([byte(0)].repeat(30).data, u32(30))
                server_id: 123456789
                rport: request.rport
                mtu_size: request.mtu_size
                security: request.security
            }
            reply.encode()
            reply.p.address = request.p.address

            s.socket.send(reply, reply.p)
            s.create_session(request.p.address, request.client_id, request.mtu_size)
        }
    }
}

fn (s SessionManager) get_session_by_address(address InternetAddress) Session {
    return s.session_by_address['$address.ip:${address.port.str()}']
}

fn (s SessionManager) session_exists(address InternetAddress) bool {
    return '$address.ip:${address.port.str()}' in s.session_by_address
}

fn (s mut SessionManager) create_session(address InternetAddress, client_id u64, mtu_size i16) &Session {
    for {
        if s.next_session_id.str() in s.sessions {
            s.next_session_id++
            s.next_session_id &= 0x7fffffff
        } else {
            break
        }
    }

    session := new_session(s, address, client_id, mtu_size, s.next_session_id)
    s.sessions[s.next_session_id.str()] = session
    s.session_by_address['$address.ip:${address.port.str()}'] = session
    return &session
}

fn (s SessionManager) send_packet(packet DataPacketHandler, p Packet) {
    s.socket.send(packet, p)
}

fn (s mut SessionManager) open_session(session Session) {
    s.server.open_session(session.internal_id.str(), session.address, session.id)
}

fn (s mut SessionManager) handle_encapsulated(session Session, packet EncapsulatedPacket) {
    s.server.handle_encapsulated(session.internal_id.str(), packet, PriorityNormal)
}