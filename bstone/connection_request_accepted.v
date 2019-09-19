module bstone

struct ConnectionRequestAccepted {
mut:
    p Packet

    ping_time i64
    pong_time i64
}

fn (r mut ConnectionRequestAccepted) encode() {
    r.p.buffer.put_byte(IdConnectionRequestAccepted)
    r.p.put_address(r.p.address)
    r.p.buffer.put_short(i16(0))

    r.p.put_address(InternetAddress { ip: '127.0.0.1', port: u16(0), version: 4 })
    mut i := 0
    for i < 9 {
        r.p.put_address(InternetAddress { ip: '0.0.0.0', port: u16(0), version: 4 })
        i++
    }
    r.p.buffer.put_long(r.ping_time)
    r.p.buffer.put_long(r.pong_time)
}

fn (r mut ConnectionRequestAccepted) decode() {}
