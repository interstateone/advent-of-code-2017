import Foundation

typealias MemoryBanks = [Int]

func redistribute(_ banks: MemoryBanks) -> MemoryBanks {
    guard
        var maxBlocks = banks.max(),
        let maxBlocksIndex = banks.index(of: maxBlocks)
    else { return banks }

    var newBanks = banks
    newBanks[maxBlocksIndex] = 0
    var currentIndex = (maxBlocksIndex + 1) % newBanks.count

    while maxBlocks > 0 {
        newBanks[currentIndex] += 1
        maxBlocks -= 1
        currentIndex = (currentIndex + 1) % newBanks.count
    }

    return newBanks
}

func lengthOfRedistributionInfiniteLoop(of banks: MemoryBanks) -> Int {
    // The redistribution count is the key, and even though the banks are what are used for lookup later, the count is already hashable and guaranteed unique
    var bankHistory: [Int: MemoryBanks] = [:]
    var currentBanks = banks
    var redistributionCount = 0

    while !bankHistory.values.contains(where: { $0 == currentBanks }) {
        bankHistory[redistributionCount] = currentBanks
        currentBanks = redistribute(currentBanks)
        redistributionCount += 1
    }

    return redistributionCount - (bankHistory.first { _, v in v == currentBanks }?.key ?? 0)
}

print(lengthOfRedistributionInfiniteLoop(of: [0, 2, 7, 0]))

let count = lengthOfRedistributionInfiniteLoop(of:
    "0    5    10    0    11    14    13    4    11    8    8    7    1    4    12    11".components(separatedBy: .whitespaces).flatMap(Int.init)
)

print(count)

