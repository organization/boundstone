module bstone

struct VRakLib {
mut:
    ip string
    port u16

    session_manager &SessionManager

    shutdown bool
}

pub fn (r mut VRakLib) start() {
    r.shutdown = false

    socket := create_socket(r.ip, int(r.port)) or { panic(err) }
    session_manager := new_session_manager(socket)
    r.session_manager = session_manager

    go session_manager.run()
}

pub fn (r mut VRakLib) stop() {
    r.shutdown = true
}