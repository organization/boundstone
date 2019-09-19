module bstone

struct OpenConnectionReply1 {
mut:
    p Packet

    security bool
    server_id i64
    mtu_size u16
}

fn (r mut OpenConnectionReply1) encode() {
    r.p.buffer.put_byte(IdOpenConnectionReply1)
    r.p.buffer.put_bytes(get_packet_magic().data, RaknetMagicLength)
    r.p.buffer.put_long(r.server_id)
    r.p.buffer.put_bool(r.security)
    r.p.buffer.put_ushort(r.mtu_size)
}

fn (r OpenConnectionReply1) decode () {}
