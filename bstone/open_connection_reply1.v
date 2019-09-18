module bstone

struct Reply1Packet {
mut:
    p Packet

    security bool
    server_id i64
    mtu_size i16
}

fn (r mut Reply1Packet) encode() {
    r.p.buffer.put_byte(IdOpenConnectionReply1)
    r.p.buffer.put_bytes(get_packet_magic().data, RaknetMagicLength)
    r.p.buffer.put_long(r.server_id)
    r.p.buffer.put_bool(r.security)
    r.p.buffer.put_short(r.mtu_size)
}

fn (r Reply1Packet) decode () {}
