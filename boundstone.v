import bstone
import readline

fn main() {
    println('Starting Server...')
    mut server := bstone.Server{
       port: 19132
       name: 'Server'
       number_of_players: 100
    }
    server.start()
    println('Server has been started')

    mut rl := readline.Readline{}
    rl.enable_raw_mode()
    for {
        line := rl.read_line('')
        if line == 'stop\n' {
            server.stop()
            break
        }
    }
    rl.disable_raw_mode()
}
