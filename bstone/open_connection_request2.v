module bstone

struct Request2Packet {
mut:
    p Packet

    security bool
    cookie int
    rport u16
    mtu_size i16
    client_id u64
}

fn (r mut Request2Packet) encode() {}

fn (r mut Request2Packet) decode() {
    r.p.buffer.get_byte() // Packet ID
    r.security = r.p.buffer.get_bool()
    r.cookie = r.p.buffer.get_int()
    r.rport = r.p.buffer.get_ushort()
    r.mtu_size = r.p.buffer.get_short()
    r.client_id = r.p.buffer.get_ulong()
}
