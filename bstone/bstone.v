module bstone

struct Server {
    port int
    number_of_players int
    name string

    player map[string]Player

mut:
    vraklib VRakLib
} 

pub fn (s mut Server) start() {
    address := InternetAddress { ip: '0.0.0.0', port: u16(19132), version: byte(4) }
    
    s.vraklib = VRakLib { server: s, address: address }
    s.vraklib.start()
}

pub fn (s mut Server) stop() {
    s.vraklib.stop()
}

pub fn (s mut Server) add_player(player Player) {
    s.player[player.hash_code().str()] = player
}