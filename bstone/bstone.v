module bstone

import vraklib

struct BoundstoneServer {
    port int
    number_of_players int
    name string

mut:
    server vraklib.UdpSocket
} 

pub fn (s mut BoundstoneServer) start() {
    println('Starting...')

    //sock := vraklib.socket(s.port) or { panic(err) }
    //s.server = sock
}