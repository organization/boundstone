module bstone

const (
    IdConnectedPing = 0x00
    IdUnConnectedPong = 0x01
    IdUnConnectedPong2 = 0x03
    IdConnectedPong = 0x03

    IdOpenConnectionRequest1 = 0x05
    IdOpenConnectionReply1 = 0x06
    IdOpenConnectionRequest2 = 0x07
    IdOpenConnectionReply2 = 0x08

    IdConnectionRequest = 0x09
    IdConnectionRequestAccepted = 0x10

    IdNewIncomingConnection = 0x13
    IdIncompatibleProtocolVersion = 0x19

    IdUnConnectedPing = 0x1c

    IdUserPacketEnum = 0x86
)

interface DataPacketHandler {
    encode()
    decode()
}
