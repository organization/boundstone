module bstone

struct Reply2Packet {
mut:
    p Packet

    server_id i64
    rport u16
    mtu_size i16
    security bool
}

fn (r mut Reply2Packet) encode() {
    r.p.buffer.put_byte(IdOpenConnectionReply2)
    r.p.buffer.put_bytes(get_packet_magic().data, RaknetMagicLength)
    r.p.buffer.put_long(r.server_id)
    r.p.buffer.put_ushort(r.rport)
    r.p.buffer.put_short(r.mtu_size)
    r.p.buffer.put_bool(r.security)
}

fn (r Reply2Packet) decode () {}
