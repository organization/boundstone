module bstone

import RakLib

struct BoundstoneServer {
    port int
    number_of_players int
    name string

mut:
    server raklib.UdpSocket
} 

pub fn (s mut BoundstoneServer) start() {
    println('Starting...')

    sock := raklib.socket(s.port) or { panic(err) }
    s.server = sock
}