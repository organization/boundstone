module boundstone

struct BoundstoneServer {
    port int
    number_of_players int
    name string
} 

pub fn (s BoundstoneServer) start() {
    println('Starting...')
}