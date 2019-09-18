module bstone

const (
    MaxSplitSize = 128
    MaxSplitCount = 4
    ChannelCount = 32
    
    MinMtuSize = 400
    window_size = 2048 //should be mutable
)

enum State {
    connecting
    connected
    disconnecting
    disconnected
}

struct TmpMapEncapsulatedPacket {
mut:
    m map[string]EncapsulatedPacket
}

struct Session {
mut:
    message_index int

    send_ordered_index []int
    send_sequenced_index []int
    receive_ordered_index []int
    receive_sequenced_highest_index []int
    receive_ordered_packets [][]EncapsulatedPacket

    session_manager SessionManager

    // logger logger

    address InternetAddress

    state State // connecting

    mtu_size int
    id int
    splid_id int // 0
    
    send_seq_number u32 // 0

    last_update f32
    disconnection_time f32

    is_temporal bool // true

    // packet_to_send 
    is_active bool // false

    ack_queue map[string]u32
    nack_queue map[string]u32

    // recovery_queue map

    split_packets map[string]TmpMapEncapsulatedPacket

    need_ack [][]int

    send_queue_data Datagram

    window_start u32
    window_end u32
    highest_seq_number u32

    reliable_window_start int
    reliable_window_end int

    reliable_window map[string]bool

    last_ping_time int // -1
    last_ping_measure int // 1

    internal_id int
}

fn (s mut Session) update() {
    diff := s.highest_seq_number - s.window_start + u32(1)
    //assert diff >= u32(0)

    if diff > u32(0) {
        s.window_start += diff
        s.window_end += diff
    }

    if s.ack_queue.size > 0 {
        //packet := Ack()
        //s.ack_queue = map[string]int{}
    }

    if s.nack_queue.size > 0 {
        //packet := Nack()
        //s.nack_queue = map[string]int{}
    }

    if s.need_ack.len > 0 {
        for i, ack in s.need_ack {
            if ack.len == 0 {
                s.need_ack[i]
                //s.session_manager.notify_ack(s, i)
            }
        }
    }

    s.send_queue()
}

fn (s Session) send_datagram(datagram Datagram) {
    mut d := datagram

    if datagram.sequence_number != u32(-1) {
        //s.recovery_queue.delete(datagram.seq_number.str())
    }
    d.sequence_number = s.send_seq_number
    s.send_seq_number++
    s.send_packet(d, d.p)
}

fn (s Session) send_packet(packet DataPacketHandler, p Packet) {
    s.session_manager.send_packet(packet, p)
}

fn (s mut Session) send_queue() {
    if s.send_queue_data.packets.len > 0 {
        s.send_datagram(s.send_queue_data)
        s.send_queue_data = Datagram {}
    }
}

fn (s mut Session) queue_connected_packet(packet Packet, reliability byte, order_channel int, flag byte) {
    mut encapsulated := EncapsulatedPacket {
        buffer: packet.buffer.buffer
        length: u16(packet.buffer.length)
        reliability: reliability
        order_channel: order_channel
    }
    s.add_encapsulated_to_queue(encapsulated, flag)
}

fn (s mut Session) add_to_queue(packet EncapsulatedPacket, flags byte) {
    mut p := packet
    priority := flags & 0x07
    if p.need_ack && p.message_index != -1 {
        mut arr := s.need_ack[p.identifier_ack]
        arr[p.message_index] = p.message_index
    }

    length := s.send_queue_data.get_total_length()
    //if length + p.get_length() > s.mtu_size - 36 {
        //s.send_queue()
    //}

    if p.need_ack {
        s.send_queue_data.packets << p
        p.need_ack = false
    } else {
        //s.send_queue_data.packets << p.to_binary()
    }

    if priority == PriorityImmediate {
        s.send_queue()
    }
}

fn (s mut Session) add_encapsulated_to_queue(packet EncapsulatedPacket, flags byte) {
    mut p := packet
    p.need_ack = (flags & 0x09) != 0
    println(p.need_ack)
    //if p.need_ack {
    //    s.need_ack[p.identifier_ack] = map[string]int
    //}

    if reliability_is_ordered(p.reliability) {
        p.order_index = s.send_ordered_index[p.order_channel]
        s.send_ordered_index[p.order_channel] += 1
    } else if reliability_is_sequenced(p.reliability) {
        p.order_index = s.send_ordered_index[p.order_channel]
        p.sequence_index = s.send_sequenced_index[p.order_channel]
        s.send_sequenced_index[p.order_channel] += 1
    }

    //max_size := mtu_size
    //if packet.length > max_size {

    //} else if {
        if reliability_is_reliable(p.reliability) {
            p.message_index = s.message_index
            s.message_index++
        }
        s.add_to_queue(p, flags)
    //}
}

fn (s mut Session) handle_packet(packet Datagram) {
    mut p := packet
    p.decode()

    if p.sequence_number < s.window_start ||
        p.sequence_number > s.window_end ||
        p.sequence_number.str() in s.ack_queue {
            // Received duplicate or out-of-window packet
            return
    }

    if p.sequence_number.str() in s.nack_queue {
       s.nack_queue.delete(p.sequence_number.str())
    }
    s.ack_queue[p.sequence_number.str()] = p.sequence_number

    if s.highest_seq_number < p.sequence_number {
        s.highest_seq_number = p.sequence_number
    }

    if p.sequence_number == s.window_start {
        for {
            if s.window_start.str() in s.ack_queue {
                s.window_end++
                s.window_start++
            } else {
                break
            }
        }
    } else if p.sequence_number > s.window_start {
        mut i := s.window_start
        for i < p.sequence_number {
            if !(i.str() in s.ack_queue) {
                s.nack_queue[i.str()] = i
            }
            i++
        }
    } else {
        // received packet before widnow start
        return
    }

    for pp in p.packets {
        s.handle_encapsulated_packet(pp)
    }
}

// max split size = 128
fn (s mut Session) handle_split(packet EncapsulatedPacket) ?EncapsulatedPacket {
    if packet.split_count >= 128 ||
        packet.split_index >= 128 ||
        packet.split_index < 0 {
            return error('Invalid split packet part')
    }

    if !(packet.split_id.str() in s.split_packets) {
        if s.split_packets.size >= 128 {
            return error('Invalid split packet part')
        }
        mut tmp := TmpMapEncapsulatedPacket{}
        tmp.m[packet.split_index.str()] = packet
        s.split_packets[packet.split_id.str()] = tmp
    } else {
        mut tmp := s.split_packets[packet.split_id.str()]
        tmp.m[packet.split_index.str()] = packet
    }

    if s.split_packets[packet.split_id.str()].m.size == packet.split_count {
        mut p := EncapsulatedPacket {}
        
        mut buffer := []byte

        p.reliability = packet.reliability
        p.message_index = packet.message_index
        p.sequence_index = packet.sequence_index
        p.order_index = packet.order_index
        p.order_channel = packet.order_channel

        mut i := 0
        for i < packet.split_count {
            d := s.split_packets[packet.split_id.str()]
            buffer << d.m[i.str()].buffer
            i++
        }

        p.buffer = buffer.data
        p.length = u16(buffer.len)
        s.split_packets.delete(packet.split_id.str())
        return p
    }
    return error('')
}

fn (s mut Session) handle_encapsulated_packet(packet EncapsulatedPacket) {
    mut p := packet
    if p.message_index != -1 {
        if p.message_index < s.reliable_window_start ||
            p.message_index > s.reliable_window_end ||
            p.message_index.str() in s.reliable_window {
                return
            }
        s.reliable_window[p.message_index.str()] = true

        if p.message_index == s.reliable_window_start {
            for {
                if s.reliable_window_start.str() in s.reliable_window {
                    s.reliable_window.delete(s.reliable_window_start.str())
                    s.reliable_window_end++
                    s.reliable_window_start++
                } else {
                    break
                }
            }
        }
    }

    if packet.has_split {
        pp := s.handle_split(packet) or { return }
        p = pp
    }

    // channel count = 32
    if reliability_is_sequenced_or_ordered(packet.reliability) &&
        (packet.order_channel < 0 || packet.order_channel >= 32) {
            // Invalid packet
            return
    }

    if reliability_is_sequenced(packet.reliability) {
        if packet.sequence_index < s.receive_sequenced_highest_index[packet.order_channel] ||
            packet.order_index < s.receive_ordered_index[packet.order_channel] {
                // too old sequenced packet
                return
        }

        s.receive_sequenced_highest_index[packet.order_channel] = packet.sequence_index + 1
        s.handle_encapsulated_packet_route(packet)
    } else if reliability_is_ordered(packet.reliability) {
        if packet.order_index == s.receive_ordered_index[packet.order_channel] {
            s.receive_sequenced_highest_index[packet.order_index] = 0
            s.receive_ordered_index[packet.order_channel] = packet.order_index + 1

            s.handle_encapsulated_packet_route(packet)
            mut i := s.receive_ordered_index[packet.order_channel]
            for {
                d := s.receive_ordered_packets[packet.order_channel]
                //if !d[i] {
                //    break
                //}
                dd := s.receive_ordered_packets[packet.order_channel]
                s.handle_encapsulated_packet_route(dd[i])
                s.receive_ordered_packets[packet.order_channel].delete(i)
                i++
            }
            s.receive_ordered_index[packet.order_channel] = i
        } else if packet.order_index > s.receive_ordered_index[packet.order_channel] {
            mut d := s.receive_ordered_packets[packet.order_channel]
            d[packet.order_index] = packet
        } else {
            // duplicate/alredy receive packet
        }
    } else {
        // not ordered or sequenced
        s.handle_encapsulated_packet_route(packet)
    }
}

fn (s mut Session) handle_encapsulated_packet_route(packet EncapsulatedPacket) {
    pid := packet.buffer[0]

    if pid < UserPacketEnum {
        if pid == ConnectionRequest {
            mut connection := ConnectionRequestPacket { p: new_packet(packet.buffer, u32(packet.length)) }
            connection.decode()

            mut accepted := ConnectionRequestAcceptedPacket {
                p: new_packet([byte(0)].repeat(96).data, u32(96))
                ping_time: connection.ping_time
                pong_time: s.session_manager.get_raknet_time_ms()
            }
            accepted.encode()
            accepted.p.ip = connection.p.ip
            accepted.p.port = connection.p.port

            s.queue_connected_packet(accepted.p, Unreliable, 0, PriorityImmediate)
        }
        else if pid == NewIncomingConnection {
            mut connection := NewIncomingConnectionPacket { p: new_packet(packet.buffer, u32(packet.length)) }
            // connection.decode();

            // if connection.address.port == s.session_manager.get_port() || s.session_manager.port_checking() {
            //     s.state = .connected
            //     s.is_temporal = false
            //     s.session_manager.open
                
            //     }

            // }
        }
    }
}