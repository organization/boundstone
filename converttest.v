fn main() {
    ushort := u16(65535)

    mut bytes := []byte

    bytes << byte(ushort & u16(0xFF))
    bytes << byte((ushort >> u16(8)) & int(0xFF))
    println(bytes[0])

    mut res := u16(0)
    res = u16((res << u16(8)) + int(bytes[1]))
    res = u16((res << u16(8)) + int(bytes[0]))
    println(res)
}