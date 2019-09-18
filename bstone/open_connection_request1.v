module bstone

struct Request1Packet {
mut:
    p Packet

    version byte
    mtu_size i16
}

fn (r mut Request1Packet) encode() {}

fn (r mut Request1Packet) decode() {
    r.p.buffer.get_byte() // Packet ID
    r.p.buffer.get_bytes(RaknetMagicLength)
    r.version = r.p.buffer.get_byte()
    r.mtu_size = i16(r.p.buffer.length - r.p.buffer.position)
}
