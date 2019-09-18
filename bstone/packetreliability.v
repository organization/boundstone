module bstone

const (
    Unreliable = 0x00
    UnreliableSequenced = 0x01
    Reliable = 0x02
    ReliableOrdered = 0x03
    ReliableSequenced = 0x04
    UnreliableWithAckReceipt = 0x05
    ReliableWithAckReceipt = 0x06
    ReliableOrderedWithAckReceipt = 0x07
)

const (
    PriorityNormal = 0
    PriorityImmediate = 1
)

fn reliability_is_reliable(reliability byte) bool {
    return reliability == Reliable ||
        reliability == ReliableOrderedWithAckReceipt ||
        reliability == ReliableSequenced ||
        reliability == ReliableWithAckReceipt ||
        reliability == ReliableOrderedWithAckReceipt
}

fn reliability_is_sequenced(reliability byte) bool {
    return reliability == UnreliableSequenced ||
        reliability == ReliableSequenced
}

fn reliability_is_ordered(reliability byte) bool {
    return reliability == ReliableOrdered ||
        reliability == ReliableOrderedWithAckReceipt
}

fn reliability_is_sequenced_or_ordered(reliability byte) bool {
    return reliability == UnreliableSequenced ||
        reliability == ReliableOrdered ||
        reliability == ReliableSequenced ||
        reliability == ReliableOrderedWithAckReceipt
}