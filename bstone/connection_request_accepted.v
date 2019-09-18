module bstone

struct ConnectionRequestAcceptedPacket {
mut:
    p Packet

    ping_time i64
    pong_time i64
}

fn (r mut ConnectionRequestAcceptedPacket) encode() {
    r.p.buffer.put_byte(IdConnectionRequestAccepted)
    put_address(mut r.p.buffer, r.p.address)
    r.p.buffer.put_short(i16(0))

    put_address(mut r.p.buffer, InternetAddress { ip: '127.0.0.1', port: u16(0), version: 4 })
    mut i := 0
    for i < 9 {
        put_address(mut r.p.buffer, InternetAddress { ip: '0.0.0.0', port: u16(0), version: 4 })
        i++
    }
    r.p.buffer.put_long(r.ping_time)
    r.p.buffer.put_long(r.pong_time)
}

fn (r mut ConnectionRequestAcceptedPacket) decode() {}
