module bstone

struct Server {
    port int
    number_of_players int
    name string

mut:
    vraklib VRakLib
} 

pub fn (s mut Server) start() {
    s.vraklib = VRakLib { ip: '0.0.0.0', port: u16(19132)}
    s.vraklib.start()
}

pub fn (s mut Server) stop() {
    s.vraklib.stop()
}