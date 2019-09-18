module bstone

const (
    ReliabilityUnreliable = 0x00
    ReliabilityUnreliableSequenced = 0x01
    ReliabilityReliable = 0x02
    ReliabilityReliableOrdered = 0x03
    ReliabilityReliableSequenced = 0x04
    ReliabilityUnreliableWithAckReceipt = 0x05
    ReliabilityReliableWithAckReceipt = 0x06
    ReliabilityReliableOrderedWithAckReceipt = 0x07
)

const (
    PriorityNormal = 0
    PriorityImmediate = 1
)

fn reliability_is_reliable(reliability byte) bool {
    return reliability == ReliabilityReliable ||
        reliability == ReliabilityReliableOrderedWithAckReceipt ||
        reliability == ReliabilityReliableSequenced ||
        reliability == ReliabilityReliableWithAckReceipt ||
        reliability == ReliabilityReliableOrderedWithAckReceipt
}

fn reliability_is_sequenced(reliability byte) bool {
    return reliability == ReliabilityUnreliableSequenced ||
        reliability == ReliabilityReliableSequenced
}

fn reliability_is_ordered(reliability byte) bool {
    return reliability == ReliabilityReliableOrdered ||
        reliability == ReliabilityReliableOrderedWithAckReceipt
}

fn reliability_is_sequenced_or_ordered(reliability byte) bool {
    return reliability == ReliabilityUnreliableSequenced ||
        reliability == ReliabilityReliableOrdered ||
        reliability == ReliabilityReliableSequenced ||
        reliability == ReliabilityReliableOrderedWithAckReceipt
}