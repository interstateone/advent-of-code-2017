import XCTest

/// Calculates the Manhattan distance from a location at a given index to the center of the grid
///
/// The grid starts in the middle and spirals out counter-clockwise:
///
/// 17  16  15  14  13
/// 18   5   4   3  12
/// 19   6   1   2  11
/// 20   7   8   9  10
/// 21  22  23  24  25
///
/// This works by finding the global coordinate of the index then calculating the Manhattan distance to (0, 0).
///
/// One simplification is to find the index of the square within it's "ring" instead of globally. An example of this would be transforming 12 into the index 2 in ring 2. This is done by finding the largest odd number which, when squared, is less than the index. That squared number is the largest number in the next largest ring. For example, 3 squared is 9, which is the largest number in the next largest ring (1) to the 12's ring 2. 12 - 9 = 3, and subtracting 1 to make this 0-indexed leaves us with 12 being at index 2 in its ring.
///
/// This ring index can be used along with the coordinate of the start of the ring to find its own coordinate. The start of each ring occurs in a pattern, note the Xs below:
///
/// 37  36  35  34  33  32  31
/// 38  17  16  15  14  13  30
/// 39  18   5   4   3  12  29
/// 40  19   6   1   X  11  28
/// 41  20   7   8   9   X  27
/// 42  21  22  23  24  25   X
/// 43  44  45  46  47  48  49
///
/// The coordinate of each ring's start index is (ringIndex, -(ringIndex - 1)).
///
/// Knowing this start coordinate means that it should be easy to find the coordinate of any following index in the ring. This is complicated by the fact that as you go around the ring, calculating the coordinate of an index will involve moving up, left, down and right from the ring's start index. Another simplification that can be made is possible because the distance of each index in a ring to the center of the grid will occur in a pattern. Consider the distances of each index in ring 2:
///
/// 4  3  2  3  4
/// 3  .  .  .  3
/// 2  .  .  .  2 (side 0)
/// 3  .  .  .  3
/// 4  3  2  3  4
///
/// There's two things to notice: 1) the minimum distance is also the ring index 2) There is a pattern here that allows simplifying how coordinates are determined. Using the known length of a side for a given ring, an index along any side can be mapped to an index along any other that has the equivalent distance to the center of the grid. For example, 22 and 12 have equivalent distances. The calculation `mappedIndex = indexWithinRing % (sideLength - 1)` will give the location along side 0 from the ring's start index. We subtract 1 from the side length because the ring's start index is always 1 above the bottom row of that ring. Note that a ring's side length - 1 is equal to the largest odd number (found earlier) + 1. For example, the mapped index of 22 will be 22 % 4 = 2, which is equal to 12's ring index.
///
/// Because the index within the ring is now mapped to a location along side 0 that only involves a difference in the Y component from the ring's start index, it's really easy to determing the index's component.

func distance(of squareIndex: Int) -> Int {
    // Trivial case
    if squareIndex == 1 { return 0 }

    let largestOddNumberSmallerThanIndex = Array(
        sequence(first: 1, next: { previous in previous + 2 })
        .prefix(while: { $0.power(2) < squareIndex })
    ).last!
    let ringIndex = largestOddNumberSmallerThanIndex / 2 + 1
    let largestNumberInNextLargestRing = largestOddNumberSmallerThanIndex.power(2)
    // Also subtract 1 so these indexes are 0-indexed
    let squareIndexWithinRing = squareIndex - largestNumberInNextLargestRing - 1
    let squareIndexWithinFirstSide = squareIndexWithinRing % (largestOddNumberSmallerThanIndex + 1)
    let ringStartCoordinate = Point(x: ringIndex, y: -(ringIndex - 1))
    let squareIndexCoordinate = ringStartCoordinate + Point(x: 0, y: squareIndexWithinFirstSide)

    return squareIndexCoordinate.distance(to: .zero)
}

struct Point {
    let x: Int
    let y: Int

    func distance(to point: Point) -> Int {
        return abs(point.x - x) + abs(point.y - y)
    }

    static func + (lhs: Point, rhs: Point) -> Point {
        return Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static let zero = Point(x: 0, y: 0)
}

extension Int {
    func power(_ exponent: Int) -> Int {
        return Int(pow(Double(self), Double(exponent)))
    }
}

class StepCounterTests: XCTestCase {
    func test1() {
        XCTAssertEqual(distance(of: 1), 0)
    }

    func test2() {
        XCTAssertEqual(distance(of: 12), 3)
    }

    func test3() {
        XCTAssertEqual(distance(of: 23), 2)
    }

    func test4() {
        XCTAssertEqual(distance(of: 1024), 31)
    }

    func test5() {
        XCTAssertEqual(distance(of: 289326), 419)
    }
}

StepCounterTests.defaultTestSuite.run()

distance(of: 289326)
