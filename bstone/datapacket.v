module bstone

const (
    IdConnectedPing = 0x00
    IdUnConnectedPong = 0x01
    IdUnConnectedPong2 = 0x03
    IdConnectedPong = 0x03

    IdOpenConnectionRequest1 = 0x05
    IdOpenConnectionReply1 = 0x06
    IdOpenConnectionRequest2 = 0x07
    IdOpenConnectionReply2 = 0x08

    IdConnectionRequest = 0x09
    IdConnectionRequestAccepted = 0x10

    IdNewIncomingConnection = 0x13
    IdIncompatibleProtocolVersion = 0x19

    IdUnConnectedPing = 0x1c

    IdUserPacketEnum = 0x86
)

interface DataPacketHandler {
    encode()
    decode()
}

// Login packets
struct UnConnectedPongPacket {
mut:
    p Packet

    server_id i64
    ping_id i64
    str string
}

struct UnConnectedPingPacket {
mut:
    p Packet

    ping_id i64
    client_id u64
}

struct Request1Packet {
mut:
    p Packet

    version byte
    mtu_size i16
}

struct Reply1Packet {
mut:
    p Packet

    security bool
    server_id i64
    mtu_size i16
}

struct Request2Packet {
mut:
    p Packet

    security bool
    cookie int
    rport u16
    mtu_size i16
    client_id u64
}

struct Reply2Packet {
mut:
    p Packet

    server_id i64
    rport u16
    mtu_size i16
    security bool
}

struct IncompatibleProtocolVersionPacket {
mut:
    p Packet

    version byte
    server_id i64
}

struct ConnectionRequestPacket {
mut:
    p Packet

    client_id i64
    ping_time i64
    use_security bool
}

struct ConnectionRequestAcceptedPacket {
mut:
    p Packet

    ping_time i64
    pong_time i64
}

/*struct NewIncomingConnectionPacket {
mut:
    p Packet

    address InternetAddress
    system_addresses []InternetAddress
    ping_time i64
    pong_time i64
}*/

// UnConnectedPong
fn (u mut UnConnectedPongPacket) encode() {
    u.p.buffer.put_byte(IdUnConnectedPing)
    u.p.buffer.put_long(u.ping_id)
    u.p.buffer.put_long(u.server_id)
    u.p.buffer.put_bytes(get_packet_magic().data, RaknetMagicLength)
    u.p.buffer.put_string(u.str)
}

fn (u UnConnectedPongPacket) decode() {}

// UnConnectedPing
fn (u mut UnConnectedPingPacket) decode() {
    u.p.buffer.get_byte() // Packet ID
    u.ping_id = u.p.buffer.get_long()
    u.p.buffer.get_bytes(RaknetMagicLength)
    u.client_id = u.p.buffer.get_ulong()
}

// Request1
fn (r mut Request1Packet) encode() {}

fn (r mut Request1Packet) decode() {
    r.p.buffer.get_byte() // Packet ID
    r.p.buffer.get_bytes(RaknetMagicLength)
    r.version = r.p.buffer.get_byte()
    r.mtu_size = i16(r.p.buffer.length - r.p.buffer.position)
}

// Reply1
fn (r mut Reply1Packet) encode() {
    r.p.buffer.put_byte(IdOpenConnectionReply1)
    r.p.buffer.put_bytes(get_packet_magic().data, RaknetMagicLength)
    r.p.buffer.put_long(r.server_id)
    r.p.buffer.put_bool(r.security)
    r.p.buffer.put_short(r.mtu_size)
}

fn (r Reply1Packet) decode () {}

// Request2
fn (r mut Request2Packet) encode() {}

fn (r mut Request2Packet) decode() {
    r.p.buffer.get_byte() // Packet ID
    r.security = r.p.buffer.get_bool()
    r.cookie = r.p.buffer.get_int()
    r.rport = r.p.buffer.get_ushort()
    r.mtu_size = r.p.buffer.get_short()
    r.client_id = r.p.buffer.get_ulong()
}

// Reply2
fn (r mut Reply2Packet) encode() {
    r.p.buffer.put_byte(IdOpenConnectionReply2)
    r.p.buffer.put_bytes(get_packet_magic().data, RaknetMagicLength)
    r.p.buffer.put_long(r.server_id)
    r.p.buffer.put_ushort(r.rport)
    r.p.buffer.put_short(r.mtu_size)
    r.p.buffer.put_bool(r.security)
}

fn (r Reply2Packet) decode () {}

// IncompatibleProtocolVersion
fn (r mut IncompatibleProtocolVersionPacket) encode() {
    r.p.buffer.put_byte(IdIncompatibleProtocolVersion)
    r.p.buffer.put_byte(r.version)
    r.p.buffer.put_bytes(get_packet_magic().data, RaknetMagicLength)
    r.p.buffer.put_long(r.server_id)
}

fn (r IncompatibleProtocolVersionPacket) decode() {}

// ConnectionRequestPacket
fn (r mut ConnectionRequestPacket) encode() {}

fn (r mut ConnectionRequestPacket) decode() {
    r.p.buffer.get_byte()
    r.client_id = r.p.buffer.get_long()
    r.ping_time = r.p.buffer.get_long()
    r.use_security = r.p.buffer.get_bool()
}

// ConnectionRequestAcceptedPacket
fn (r mut ConnectionRequestAcceptedPacket) encode() {
    r.p.buffer.put_byte(IdConnectionRequestAccepted)
    put_address(mut r.p.buffer, r.p.address)
    r.p.buffer.put_short(i16(0))

    put_address(mut r.p.buffer, InternetAddress { ip: '127.0.0.1', port: u16(0), version: 4 })
    mut i := 0
    for i < 9 {
        put_address(mut r.p.buffer, InternetAddress { ip: '0.0.0.0', port: u16(0), version: 4 })
        i++
    }
    r.p.buffer.put_long(r.ping_time)
    r.p.buffer.put_long(r.pong_time)

}

fn (r mut ConnectionRequestAcceptedPacket) decode() {}

fn put_address(buffer mut ByteBuffer, address InternetAddress) {
    buffer.put_byte(byte(0x04))
    numbers := address.ip.split('.')
    for num in numbers {
        buffer.put_char(i8(~num.int() & 0xFF))
    }
    buffer.put_ushort(u16(address.port))
}

/*
// NewIncomingConnectionPacket
fn (n mut NewIncomingConnectionPacket) encode() {
    n.p.buffer.put_byte(IdNewIncomingConnection)
    //putaddrees
    //putaddress
    //n.p.buffer.put_long()
    //n.p.buffer.put_long()
}

fn (n mut NewIncomingConnectionPacket) decode() {}*/