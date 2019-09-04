import boundstone

fn main() {
    println('Starting Server...')
    mut server := BoundstoneServer{
        port: 19132
        name: 'Server'
        number_of_players: 100
    }
    server.start()
    println('Server has been started')
}
