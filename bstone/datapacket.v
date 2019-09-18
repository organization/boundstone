module bstone

const (
    ConnectedPing = 0x00
    UnConnectedPong = 0x01
    UnConnectedPong2 = 0x03
    ConnectedPong = 0x03

    OpenConnectionRequest1 = 0x05
    OpenConnectionReply1 = 0x06
    OpenConnectionRequest2 = 0x07
    OpenConnectionReply2 = 0x08

    ConnectionRequest = 0x09
    ConnectionRequestAccepted = 0x10

    NewIncomingConnection = 0x13
    IncompatibleProtocolVersion = 0x19

    UnConnectedPing = 0x1c

    UserPacketEnum = 0x86
)

interface DataPacketHandler {
    encode()
    decode()
}

// Login packets











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

struct NewIncomingConnectionPacket {
mut:
    p Packet

    address InternetAddress
    system_addresses []InternetAddress
    ping_time i64
    pong_time i64
}

// UnConnectedPong


// UnConnectedPing


// Request1


// Reply1


// Request2


// Reply2


// IncompatibleProtocolVersion
fn (r mut IncompatibleProtocolVersionPacket) encode() {
    r.p.buffer.put_byte(IncompatibleProtocolVersion)
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
    r.p.buffer.put_byte(ConnectionRequestAccepted)
    put_address(mut r.p.buffer, r.p.ip, r.p.port)
    r.p.buffer.put_short(i16(0))

    put_address(mut r.p.buffer, '127.0.0.1', 0)
    mut i := 0
    for i < 9 {
        put_address(mut r.p.buffer, '0.0.0.0', 0)
        i++
    }
    r.p.buffer.put_long(r.ping_time)
    r.p.buffer.put_long(r.pong_time)

}

fn (r mut ConnectionRequestAcceptedPacket) decode() {}

// NewIncomingConnectionPacket
fn (r mut NewIncomingConnectionPacket) decode() {
    
}


fn put_address(buffer mut ByteBuffer, ip string, port int) {
    buffer.put_byte(byte(0x04))
    numbers := ip.split('.')
    for num in numbers {
        buffer.put_char(i8(~num.int() & 0xFF))
    }
    buffer.put_ushort(u16(port))
}