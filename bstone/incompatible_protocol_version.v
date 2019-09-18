module bstone

struct IncompatibleProtocolVersionPacket {
mut:
    p Packet

    version byte
    server_id i64
}

fn (r mut IncompatibleProtocolVersionPacket) encode() {
    r.p.buffer.put_byte(IdIncompatibleProtocolVersion)
    r.p.buffer.put_byte(r.version)
    r.p.buffer.put_bytes(get_packet_magic().data, RaknetMagicLength)
    r.p.buffer.put_long(r.server_id)
}

fn (r IncompatibleProtocolVersionPacket) decode() {}
