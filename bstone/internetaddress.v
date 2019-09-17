module bstone

struct InternetAddress {
mut:
    ip string
    port u16
    version byte
}