module bstone

import vraklib

struct BoundstoneServer {
    port int
    number_of_players int
    name string

mut:
    vraklib vraklib.VRakLib
} 

pub fn (s mut BoundstoneServer) start() {
    s.vraklib = vraklib.VRakLib { ip: '0.0.0.0', port: u16(19132)}
    s.vraklib.start()
}

pub fn (s mut BoundstoneServer) stop() {
    s.vraklib.stop()
}