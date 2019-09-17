module bstone

struct VRakLib {
mut:
    server Server

    address InternetAddress

    session_manager &SessionManager

    shutdown bool

    players map[string]Player
    identifiers map[string]string
}

pub fn (r mut VRakLib) start() {
    r.shutdown = false

    socket := create_socket(r.address.ip, int(r.address.port)) or { panic(err) }
    session_manager := new_session_manager(r, socket)
    r.session_manager = session_manager

    go session_manager.run()
}

pub fn (r mut VRakLib) stop() {
    r.shutdown = true
}

fn (r VRakLib) close_session() {

}

fn (r mut VRakLib) open_session(identifier string, address InternetAddress, client_id u64) {
    player := new_player(r, r.server, address.ip, address.port)
    r.players[identifier] = player
    r.identifiers[player.hash_code().str()] = identifier
    r.server.add_player(player)
}

fn (r VRakLib) handle_encapsulated(identifier string, packet EncapsulatedPacket, flags int) {
    if identifier in r.players {
        player := r.players[identifier]
        address := player.ip
        println(address)

        //p := BatchPacket {}
        //player.handle_data_packet(p)
    }
}

fn (r VRakLib) put_packet(player Player, packet Packet, need_ack bool, immediate bool) {

}

fn (r VRakLib) update_ping() {
    
}