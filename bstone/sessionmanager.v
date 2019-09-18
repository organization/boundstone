module bstone

struct SessionManager {
mut:
    socket UdpSocket
    sessions []Session
    session_by_address map[string]Session

    shutdown bool

    start_time_ms int
}

fn new_session_manager(socket UdpSocket) &SessionManager {
    sm := &SessionManager {
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

    if s.session_exists(packet.ip, packet.port) {
        mut session := s.get_session_by_address(packet.ip, packet.port)

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
        if pid == UnConnectedPong || pid == UnConnectedPong2 {
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
            pong.p.ip = ping.p.ip
            pong.p.port = ping.p.port

            s.socket.send(pong, pong.p)
        } else if pid == OpenConnectionRequest1 {
            mut request := Request1Packet { p: new_packet_from_packet(packet) }
            request.decode()
            
            if request.version != 9 {
                mut incompatible := IncompatibleProtocolVersionPacket {
                    p: new_packet([byte(0)].repeat(26).data, u32(26))
                    version: 9
                    server_id: 123456789
                }
                incompatible.encode()
                incompatible.p.ip = request.p.ip
                incompatible.p.port = request.p.port

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
            reply.p.ip = request.p.ip
            reply.p.port = request.p.port

            s.socket.send(reply, reply.p)
        } else if pid == OpenConnectionRequest2 {
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
            reply.p.ip = request.p.ip
            reply.p.port = request.p.port

            s.socket.send(reply, reply.p)
            s.create_session(request.p.ip, request.p.port)
        }
    }
}

fn (s SessionManager) get_session_by_address(ip string, port int) Session {
    return s.session_by_address['$ip:${port.str()}']
}

fn (s SessionManager) session_exists(ip string, port int) bool {
    return '$ip:${port.str()}' in s.session_by_address
}

fn (s mut SessionManager) create_session(ip string, port int) &Session {
    mut session := Session {
        session_manager: s
        address: InternetAddress {
            ip: ip
            port: u16(port)
        }
        send_ordered_index: [0].repeat(32)
        send_sequenced_index: [0].repeat(32)

        receive_ordered_index: [0].repeat(32)
        receive_sequenced_highest_index: [0].repeat(32)

        receive_ordered_packets: [[]EncapsulatedPacket].repeat(32)
    }
    s.sessions << session
    s.session_by_address['$ip:${port.str()}'] = session
    return &session
}

fn (s SessionManager) send_packet(packet DataPacketHandler, p Packet) {
    s.socket.send(packet, p)
}