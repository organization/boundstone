module bstone

struct UnConnectedPing {
mut:
    p Packet

    ping_id i64
    client_id u64
}

fn (u UnConnectedPing) encode() {}

fn (u mut UnConnectedPing) decode() {
    u.p.buffer.get_byte() // Packet ID
    u.ping_id = u.p.buffer.get_long()
    u.p.buffer.get_bytes(RaknetMagicLength)
    u.client_id = u.p.buffer.get_ulong()
}