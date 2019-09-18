module bstone

struct InternetAddress {
    mut:
    ip string
    port u16
    version byte
}

fn put_address(buffer mut ByteBuffer, ip string, port int) {
    buffer.put_byte(byte(0x04))
    numbers := ip.split('.')
    for num in numbers {
        buffer.put_char(i8(~num.int() & 0xFF))
    }
    buffer.put_ushort(u16(port))
}
