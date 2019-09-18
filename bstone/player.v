module bstone

struct Player {
    vraklib VRakLib

    server Server
    ip string
    port u16
}

pub fn new_player(vraklib VRakLib, server Server, ip string, port u16) Player {
    return Player {
        vraklib: vraklib
        server: server
        ip: ip
        port: port
    }
}

fn (p Player) handle_data_packet(packet Packet) {
    
}

fn (p Player) hash_code() int {
    return 0
}