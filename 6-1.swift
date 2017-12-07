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

func redistributionsUntilRepeat(of banks: MemoryBanks) -> Int {
    var bankHistory: [MemoryBanks] = []
    var currentBanks = banks
    var redistributionCount = 0

    while !bankHistory.contains(where: { $0 == currentBanks }) {
        bankHistory.append(currentBanks)
        currentBanks = redistribute(currentBanks)
        redistributionCount += 1
    }

    return redistributionCount
}

//expect(redistribute([0, 2, 7, 0])).to(equal([2, 4, 1, 2]))
//expect(redistributionsUntilRepeat(of: [0, 2, 7, 0])).to(equal(5))

let count = redistributionsUntilRepeat(of:
    "0    5    10    0    11    14    13    4    11    8    8    7    1    4    12    11".components(separatedBy: .whitespaces).flatMap(Int.init)
)

print(count)

