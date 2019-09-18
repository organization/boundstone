module bstone

struct NewIncomingConnectionPacket {
mut:
    p Packet

    address InternetAddress
    system_addresses []InternetAddress
    ping_time i64
    pong_time i64
}

fn (r mut NewIncomingConnectionPacket) decode() {
    
}
