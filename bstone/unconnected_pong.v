module bstone

struct UnConnectedPong {
mut:
    p Packet

    server_id i64
    ping_id i64
    str string
}

fn (u mut UnConnectedPong) encode() {
    u.p.buffer.put_byte(IdUnConnectedPong)
    u.p.buffer.put_long(u.ping_id)
    u.p.buffer.put_long(u.server_id)
    u.p.buffer.put_bytes(get_packet_magic().data, RaknetMagicLength)
    u.p.buffer.put_string(u.str)
}

fn (u UnConnectedPong) decode() {}