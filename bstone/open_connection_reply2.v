module bstone

struct OpenConnectionReply2 {
mut:
    p Packet

    server_id i64
    client_address InternetAddress
    mtu_size u16
    security bool
}

fn (r mut OpenConnectionReply2) encode() {
    r.p.buffer.put_byte(IdOpenConnectionReply2)
    r.p.buffer.put_bytes(get_packet_magic().data, RaknetMagicLength)
    r.p.buffer.put_long(r.server_id)
    r.p.put_address(r.client_address)
    r.p.buffer.put_ushort(r.mtu_size)
    r.p.buffer.put_bool(r.security)
}

fn (r OpenConnectionReply2) decode () {}
