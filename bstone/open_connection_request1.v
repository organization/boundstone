module bstone

struct OpenConnectionRequest1 {
mut:
    p Packet

    version byte
    mtu_size u16
}

fn (r mut OpenConnectionRequest1) encode() {}

fn (r mut OpenConnectionRequest1) decode() {
    r.p.buffer.get_byte() // Packet ID
    r.p.buffer.get_bytes(RaknetMagicLength)
    r.version = r.p.buffer.get_byte()
    r.mtu_size = u16(r.p.buffer.length - r.p.buffer.position)
}
