module bstone

struct InternetAddress {
mut:
    ip string
    port u16
    version byte
}

fn put_address(buffer mut ByteBuffer, address InternetAddress) {
    buffer.put_byte(byte(0x04))
    numbers := address.ip.split('.')
    for num in numbers {
        buffer.put_char(i8(~num.int() & 0xFF))
    }
    buffer.put_ushort(u16(address.port))
}
