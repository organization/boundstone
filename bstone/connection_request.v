module bstone

struct ConnectionRequestPacket {
mut:
    p Packet

    client_id i64
    ping_time i64
    use_security bool
}

fn (r mut ConnectionRequestPacket) encode() {}

fn (r mut ConnectionRequestPacket) decode() {
    r.p.buffer.get_byte()
    r.client_id = r.p.buffer.get_long()
    r.ping_time = r.p.buffer.get_long()
    r.use_security = r.p.buffer.get_bool()
}
