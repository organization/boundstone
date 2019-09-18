module bstone

enum Endianness {
    little big
}

struct ByteBuffer {
pub mut:
    endianness Endianness
    buffer byteptr
    length u32
    position u32
}

pub fn new_bytebuffer(buffer byteptr, size u32) ByteBuffer {
    return ByteBuffer{
        endianness: Endianness.little // Network order
        buffer: buffer
        length: size
        position: u32(0)
    }
}

pub fn (b mut ByteBuffer) put_byte(v byte) {
    //assert b.position + u32(sizeof(byte)) <= b.length
    b.buffer[b.position] = v
    b.position++
}

pub fn (b mut ByteBuffer) put_bytes(bytes byteptr, size int) {
    //assert b.position + u32(size) <= b.length
    if size > 0 {
        mut i := 0
        for i < size {
            b.buffer[b.position + u32(i)] = bytes[i]
            i++
        }
        b.position += u32(size)
    }
}

pub fn (b mut ByteBuffer) put_char(c i8) {
    //assert b.position + u32(sizeof(i8)) <= b.length
    b.buffer[b.position] = byte(c)
    b.position++
}

pub fn (b mut ByteBuffer) put_bool(v bool) {
    //assert b.position + u32(1) <= b.length
    b.buffer[b.position] = if v { 0x01 } else { 0x00 }
    b.position++
}

pub fn (b mut ByteBuffer) put_short(v i16) {
    //assert b.position + u32(sizeof(i16)) <= b.length

    mut vv := v
    if b.get_system_endianness() != b.endianness {
        vv = i16(swap16(u16(v)))
    }
    b.buffer[b.position         ] = byte(vv >> i16(8))
    b.buffer[b.position + u32(1)] = byte(vv)
    b.position += u32(sizeof(i16))
}

pub fn (b mut ByteBuffer) put_ushort(v u16) {
    //assert b.position + u32(sizeof(u16)) <= b.length

    mut vv := v
    if b.get_system_endianness() != b.endianness {
        vv = swap16(v)
    }
    b.buffer[b.position         ] = byte(vv >> u16(8))
    b.buffer[b.position + u32(1)] = byte(vv)
    b.position += u32(sizeof(u16))
}

pub fn (b mut ByteBuffer) put_triad(v int) {
    //assert b.position + u32(3) <= b.length
    b.buffer[b.position         ] = byte(v >> 16)
    b.buffer[b.position + u32(1)] = byte(v >> 8)
    b.buffer[b.position + u32(2)] = byte(v)
    b.position += u32(3)
}

pub fn (b mut ByteBuffer) put_ltriad(v int) {
    //assert b.position + u32(3) <= b.length
    b.buffer[b.position         ] = byte(v)
    b.buffer[b.position + u32(1)] = byte(v >> 8)
    b.buffer[b.position + u32(2)] = byte(v >> 16)
    b.position += u32(3)
}

pub fn (b mut ByteBuffer) put_int(v int) {
    //assert b.position + u32(sizeof(int)) <= b.length

    mut vv := v
    if b.get_system_endianness() != b.endianness {
        vv = int(swap32(u32(v)))
    }
    b.buffer[b.position         ] = byte(vv >> int(24))
    b.buffer[b.position + u32(1)] = byte(vv >> int(16))
    b.buffer[b.position + u32(2)] = byte(vv >> int(8))
    b.buffer[b.position + u32(3)] = byte(vv)
    b.position += u32(sizeof(int))
}

pub fn (b mut ByteBuffer) put_uint(v u32) {
    //assert b.position + u32(sizeof(u32)) <= b.length

    mut vv := v
    if b.get_system_endianness() != b.endianness {
        vv = swap32(v)
    }
    b.buffer[b.position         ] = byte(vv >> u32(24))
    b.buffer[b.position + u32(1)] = byte(vv >> u32(16))
    b.buffer[b.position + u32(2)] = byte(vv >> u32(8))
    b.buffer[b.position + u32(3)] = byte(vv)
    b.position += u32(sizeof(u32))
}

pub fn (b mut ByteBuffer) put_long(v i64) {
    //assert b.position + u32(sizeof(i64)) <= b.length

    mut vv := v
    if b.get_system_endianness() != b.endianness {
        vv = i64(swap64(u64(v)))
    }
    b.buffer[b.position         ] = byte(vv >> i64(56))
    b.buffer[b.position + u32(1)] = byte(vv >> i64(48))
    b.buffer[b.position + u32(2)] = byte(vv >> i64(40))
    b.buffer[b.position + u32(3)] = byte(vv >> i64(32))
    b.buffer[b.position + u32(4)] = byte(vv >> i64(24))
    b.buffer[b.position + u32(5)] = byte(vv >> i64(16))
    b.buffer[b.position + u32(6)] = byte(vv >> i64(8))
    b.buffer[b.position + u32(7)] = byte(vv)
    b.position += u32(sizeof(i64))
}

pub fn (b mut ByteBuffer) put_ulong(v u64) {
    //assert b.position + u32(sizeof(u64)) <= b.length

    mut vv := v
    if b.get_system_endianness() != b.endianness {
        vv = swap64(v)
    }
    b.buffer[b.position         ] = byte(vv >> u64(56))
    b.buffer[b.position + u32(1)] = byte(vv >> u64(48))
    b.buffer[b.position + u32(2)] = byte(vv >> u64(40))
    b.buffer[b.position + u32(3)] = byte(vv >> u64(32))
    b.buffer[b.position + u32(4)] = byte(vv >> u64(24))
    b.buffer[b.position + u32(5)] = byte(vv >> u64(16))
    b.buffer[b.position + u32(6)] = byte(vv >> u64(8))
    b.buffer[b.position + u32(7)] = byte(vv)
    b.position += u32(sizeof(u64))
}

pub fn (b mut ByteBuffer) put_float(v f32) {
    //assert b.position + u32(sizeof(f32)) <= b.length

    mut vv := v
    if b.get_system_endianness() != b.endianness {
        vv = swapf(v)
    }
    as_int := &u32(&vv)
    b.buffer[b.position         ] = byte(u32(*as_int) >> u32(24))
    b.buffer[b.position + u32(1)] = byte(u32(*as_int) >> u32(16))
    b.buffer[b.position + u32(2)] = byte(u32(*as_int) >> u32(8))
    b.buffer[b.position + u32(3)] = byte(u32(*as_int))
    b.position += u32(sizeof(f32))
}

pub fn (b mut ByteBuffer) put_double(v f64) {
    //assert b.position + u32(sizeof(f64)) <= b.length

    mut vv := v
    if b.get_system_endianness() != b.endianness {
        vv = swapd(v)
    }
    as_int := &u64(&vv)
    b.buffer[b.position         ] = byte(u64(*as_int) >> u64(56))
    b.buffer[b.position + u32(1)] = byte(u64(*as_int) >> u64(48))
    b.buffer[b.position + u32(2)] = byte(u64(*as_int) >> u64(40))
    b.buffer[b.position + u32(3)] = byte(u64(*as_int) >> u64(32))
    b.buffer[b.position + u32(4)] = byte(u64(*as_int) >> u64(24))
    b.buffer[b.position + u32(5)] = byte(u64(*as_int) >> u64(16))
    b.buffer[b.position + u32(6)] = byte(u64(*as_int) >> u64(8))
    b.buffer[b.position + u32(7)] = byte(u64(*as_int))
    b.position += u32(sizeof(f64))
}

pub fn (b mut ByteBuffer) put_string(v string) {
    b.put_short(i16(v.len))
    if v.len != 0 {
        //assert b.position + u32(v.len) <= b.length
        for c in v.bytes() {
            b.buffer[b.position] = c
            b.position++
        }
    }
}

pub fn (b mut ByteBuffer) get_bytes(size int) byteptr {
    //assert b.position + u32(size) <= b.length

    if size == 0 {
        //return []byte
    }

    mut v := []byte

    mut i := 0
    for i < size {
        v << b.buffer[b.position + u32(i)]
        i++
    }
    b.position += u32(size)
    return v.data
}

pub fn (b mut ByteBuffer) get_byte() byte {
    //assert b.position + u32(sizeof(byte)) <= b.length
    v := b.buffer[b.position]
    b.position++
    return v
}

pub fn (b mut ByteBuffer) get_char() i8 {
    //assert b.position + u32(sizeof(i8)) <= b.length
    v := i8(b.buffer[b.position])
    b.position++
    return v
}

pub fn (b mut ByteBuffer) get_bool() bool {
    //assert b.position + u32(1) <= b.length
    v := if b.buffer[b.position] == 0x01 { true } else { false }
    b.position++
    return v
}

pub fn (b mut ByteBuffer) get_short() i16 {
    //assert b.position + u32(sizeof(i16)) <= b.length
    mut v := i16(i16(b.buffer[b.position]) << i16(8)) |
        i16(b.buffer[b.position + u32(1)])
    b.position += u32(sizeof(i16))
    if b.get_system_endianness() != b.endianness {
        v = i16(swap16(u16(v)))
    }
    return v
}

pub fn (b mut ByteBuffer) get_ushort() u16 {
    //assert b.position + u32(sizeof(u16)) <= b.length
    mut v := u16(u16(b.buffer[b.position]) << u16(8)) |
        u16(b.buffer[b.position + u32(1)])
    b.position += u32(sizeof(u16))
    if b.get_system_endianness() != b.endianness {
        v = swap16(v)
    }
    return v
}

pub fn (b mut ByteBuffer) get_triad() int {
    //assert b.position + u32(3) <= b.length
    v := int(int(b.buffer[b.position]) << int(16)) |
        int(int(b.buffer[b.position + u32(1)]) << int(8)) |
        int(b.buffer[b.position + u32(2)])
    b.position += u32(3)
    return v
}

pub fn (b mut ByteBuffer) get_ltriad() int {
    //assert b.position + u32(3) <= b.length
    v := int(b.buffer[b.position]) |
        int(int(b.buffer[b.position + u32(1)]) << int(8)) |
        int(int(b.buffer[b.position + u32(2)]) << int(16))
    b.position += u32(3)
    return v
}

pub fn (b mut ByteBuffer) get_int() int {
    //assert b.position + u32(sizeof(int)) <= b.length
    mut v := int(int(b.buffer[b.position]) << int(24)) |
        int(int(b.buffer[b.position + u32(1)]) << int(16)) |
        int(int(b.buffer[b.position + u32(2)]) << int(8)) |
        int(b.buffer[b.position + u32(3)])
    b.position += u32(sizeof(int))
    if b.get_system_endianness() != b.endianness {
        v = int(swap32(u32(v)))
    }
    return v
}

pub fn (b mut ByteBuffer) get_uint() u32 {
    //assert b.position + u32(sizeof(u32)) <= b.length
    mut v := u32(u32(b.buffer[b.position]) << u32(24)) |
        u32(u32(b.buffer[b.position + u32(1)]) << u32(16)) |
        u32(u32(b.buffer[b.position + u32(2)]) << u32(8)) |
        u32(b.buffer[b.position + u32(3)])
    b.position += u32(sizeof(u32))
    if b.get_system_endianness() != b.endianness {
        v = swap32(v)
    }
    return v
}

pub fn (b mut ByteBuffer) get_long() i64 {
    //assert b.position + u32(sizeof(i64)) <= b.length
    mut v := i64(i64(b.buffer[b.position]) << i64(56)) |
        i64(i64(b.buffer[b.position + u32(1)]) << i64(48)) |
        i64(i64(b.buffer[b.position + u32(2)]) << i64(40)) |
        i64(i64(b.buffer[b.position + u32(3)]) << i64(32)) |
        i64(i64(b.buffer[b.position + u32(4)]) << i64(24)) |
        i64(i64(b.buffer[b.position + u32(5)]) << i64(16)) |
        i64(i64(b.buffer[b.position + u32(6)]) << i64(8)) |
        i64(b.buffer[b.position + u32(7)])
    b.position += u32(sizeof(i64))
    if b.get_system_endianness() != b.endianness {
        v = i64(swap64(u64(v)))
    }
    return v
}

pub fn (b mut ByteBuffer) get_ulong() u64 {
    //assert b.position + u32(sizeof(u64)) <= b.length
    mut v := u64(u64(b.buffer[b.position]) << u64(56)) |
        u64(u64(b.buffer[b.position + u32(1)]) << u64(48)) |
        u64(u64(b.buffer[b.position + u32(2)]) << u64(40)) |
        u64(u64(b.buffer[b.position + u32(3)]) << u64(32)) |
        u64(u64(b.buffer[b.position + u32(4)]) << u64(24)) |
        u64(u64(b.buffer[b.position + u32(5)]) << u64(16)) |
        u64(u64(b.buffer[b.position + u32(6)]) << u64(8)) |
        u64(b.buffer[b.position + u32(7)])
    b.position += u32(sizeof(u64))
    if b.get_system_endianness() != b.endianness {
        v = swap64(v)
    }
    return v
}

pub fn (b mut ByteBuffer) get_float() f32 {
    //assert b.position + u32(sizeof(f32)) <= b.length
    mut v := u32(u32(b.buffer[b.position]) << u32(24)) |
        u32(u32(b.buffer[b.position + u32(1)]) << u32(16)) |
        u32(u32(b.buffer[b.position + u32(2)]) << u32(8)) |
        u32(b.buffer[b.position + u32(3)])
    ptr := &f32(&v)
    b.position += u32(sizeof(f32))

    mut vv := *ptr
    if b.get_system_endianness() != b.endianness {
        vv = swapf(vv)
    }
    return vv
}

pub fn (b mut ByteBuffer) get_double() f64 {
    //assert b.position + u32(sizeof(f64)) <= b.length
    mut v := u64(u64(b.buffer[b.position]) << u64(56)) |
        u64(u64(b.buffer[b.position + u32(1)]) << u64(48)) |
        u64(u64(b.buffer[b.position + u32(2)]) << u64(40)) |
        u64(u64(b.buffer[b.position + u32(3)]) << u64(32)) |
        u64(u64(b.buffer[b.position + u32(4)]) << u64(24)) |
        u64(u64(b.buffer[b.position + u32(5)]) << u64(16)) |
        u64(u64(b.buffer[b.position + u32(6)]) << u64(8)) |
        u64(b.buffer[b.position + u32(7)])
    ptr := &f64(&v)
    b.position += u32(sizeof(f64))

    mut vv := *ptr
    if b.get_system_endianness() != b.endianness {
        vv = swapd(vv)
    }
    return vv
}

pub fn (b mut ByteBuffer) get_string() string {
    size := int(b.get_short())

    mut v := []byte
    if size > 0 {
        //assert b.position + u32(sizeof(string)) <= b.length
        mut i := 0
        for i < size {
            v << b.buffer[b.position] & 0xFF
            b.position++
            i++
        }
    }
    return tos(v.data, size)
}

pub fn (b ByteBuffer) get_system_endianness() Endianness {
    if C.__BYTE_ORDER__ == C.__ORDER_LITTLE_ENDIAN__ {
        return Endianness.little
    }
    else {
        return Endianness.big
    }
}

pub fn (b ByteBuffer) print() {
    mut i := 0
    mut str := ''
    for i < int(b.length) {
        str += b.buffer[i].hex() + ' '
        if (i + 1) % 8 == 0 || i == int(b.length) - 1 {
            str += '\n'
        }
        i++
    }
    println(str)
}

pub fn swap16(v u16) u16 {
    return u16(v >> u16(8)) | u16(v << u16(8))
}

pub fn swap32(v u32) u32 {
    return u32(u32(swap16(u16(v))) << u32(16)) | u32(swap16(u16(v >> u32(16))))
}

pub fn swap64(v u64) u64 {
    return u64(u64(swap32(u32(v))) << u64(32)) | u64(swap32(u32(v >> u64(32))))
}

pub fn swapf(f f32) f32 {
    //assert sizeof(u32) == sizeof(f32)

    as_int := &u32(&f)
    v := swap32(u32(*as_int))
    as_float := &f32(&v)
    return *as_float
}

pub fn swapd(d f64) f64 {
    //assert sizeof(u64) == sizeof(f64)

    as_int := &u64(&d)
    v := swap64(u64(*as_int))
    as_double := &f64(&v)
    return *as_double
}