module bstone

import vraklib

struct Server {
    port int
    number_of_players int
    name string

mut:
    vraklib vraklib.VRakLib
} 

pub fn (s mut Server) start() {
    s.vraklib = vraklib.VRakLib { ip: '0.0.0.0', port: u16(19132)}
    s.vraklib.start()
}

pub fn (s mut Server) stop() {
    s.vraklib.stop()
}