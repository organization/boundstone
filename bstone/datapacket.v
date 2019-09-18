module bstone

const (
    ConnectedPing = 0x00
    UnConnectedPong = 0x01
    UnConnectedPong2 = 0x03
    ConnectedPong = 0x03

    OpenConnectionRequest1 = 0x05
    OpenConnectionReply1 = 0x06
    OpenConnectionRequest2 = 0x07
    OpenConnectionReply2 = 0x08

    ConnectionRequest = 0x09
    ConnectionRequestAccepted = 0x10

    NewIncomingConnection = 0x13
    IncompatibleProtocolVersion = 0x19

    UnConnectedPing = 0x1c

    UserPacketEnum = 0x86
)

interface DataPacketHandler {
    encode()
    decode()
}
