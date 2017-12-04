import XCTest

func distance(of squareIndex: Int) -> Int {
    // Trivial case
    if squareIndex == 1 { return 0 }
    return coordinate(of: squareIndex).distance(to: .zero)
}

/// Determines the coordinate of the square at an index from the center
/// Can't perform the simplification used in 3-1 that mapped index around any side of a ring to side 0, because in order to calculate square values the actual coordinate is needed
/// Square indexes are 1-indexed, based on the puzzle, but this is inconsistent in the implementation
func coordinate(of squareIndex: Int) -> Point {
    if squareIndex == 1 { return .zero }

    let largestOddNumberSmallerThanIndex = Array(
        sequence(first: 1, next: { previous in previous + 2 })
        .prefix(while: { $0.power(2) < squareIndex })
    ).last!

    let ringIndex = largestOddNumberSmallerThanIndex / 2 + 1
    let largestNumberInNextLargestRing = largestOddNumberSmallerThanIndex.power(2)

    // Also subtract 1 so these indexes are 0-indexed
    let squareIndexWithinRing = squareIndex - largestNumberInNextLargestRing - 1
    let ringStartCoordinate = Point(x: ringIndex, y: -(ringIndex - 1))
    let sideLength = largestOddNumberSmallerThanIndex + 1

    // Calculate the coordinate for the square based on its index within its ring
    // This is garbage at the moment, but it works
    switch squareIndexWithinRing {
    case 0..<sideLength:
        return ringStartCoordinate + Point(x: 0, y: squareIndexWithinRing)
    case sideLength..<(sideLength * 2):
        return ringStartCoordinate + Point(x: -(squareIndexWithinRing - sideLength) - 1, y: sideLength - 1)
    case (sideLength * 2)..<(sideLength * 3):
        return ringStartCoordinate + Point(x: -sideLength, y: (sideLength - 1) - (squareIndexWithinRing - (sideLength * 2)) - 1)
    case (sideLength * 3)..<(sideLength * 4):
        return ringStartCoordinate + Point(x: -sideLength + (squareIndexWithinRing - (sideLength * 3) + 1), y: -1)
    default:
        assertionFailure()
        return .zero
    }
}

func surroundingCoordinates(of coordinate: Point) -> Set<Point> {
    return [
        (coordinate + Point(x: -1, y: 1)),  (coordinate + Point(x: 0, y: 1)),  (coordinate + Point(x: 1, y: 1)),
        (coordinate + Point(x: -1, y: 0)),                                     (coordinate + Point(x: 1, y: 0)),
        (coordinate + Point(x: -1, y: -1)), (coordinate + Point(x: 0, y: -1)), (coordinate + Point(x: 1, y: -1))
    ]
}

func firstValue(largerThan value: Int) -> Int {
    return sequence(
        state: (squares: [Point.zero: 1], values: [1]),
        next: { state in
            let coord = coordinate(of: state.values.count + 1)
            let value = surroundingCoordinates(of: coord)
                .reduce(0) { sum, coordinate in
                    return sum + (state.squares[coordinate] ?? 0)
            }

            state.squares[coord] = value
            state.values.append(value)

            return value
        })
        .first { $0 > value } ?? 0
}

struct Point: Equatable, Hashable {
    let x: Int
    let y: Int

    func distance(to point: Point) -> Int {
        return abs(point.x - x) + abs(point.y - y)
    }

    static func + (lhs: Point, rhs: Point) -> Point {
        return Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static let zero = Point(x: 0, y: 0)

    static func == (lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    var hashValue: Int {
        return x ^ y
    }
}

extension Int {
    func power(_ exponent: Int) -> Int {
        return Int(pow(Double(self), Double(exponent)))
    }
}

class GridSumTests: XCTestCase {
    func test1() {
        XCTAssertEqual(distance(of: 1), 0)
        XCTAssertEqual(distance(of: 12), 3)
        XCTAssertEqual(distance(of: 23), 2)
        XCTAssertEqual(distance(of: 1024), 31)
        XCTAssertEqual(distance(of: 289326), 419)
    }

    func test2() {
        XCTAssertEqual(coordinate(of: 1), .zero)
        XCTAssertEqual(coordinate(of: 2), Point(x: 1, y: 0))
        XCTAssertEqual(coordinate(of: 3), Point(x: 1, y: 1))
        XCTAssertEqual(coordinate(of: 4), Point(x: 0, y: 1))
        XCTAssertEqual(coordinate(of: 5), Point(x: -1, y: 1))
        XCTAssertEqual(coordinate(of: 6), Point(x: -1, y: 0))
        XCTAssertEqual(coordinate(of: 7), Point(x: -1, y: -1))
        XCTAssertEqual(coordinate(of: 8), Point(x: 0, y: -1))
        XCTAssertEqual(coordinate(of: 9), Point(x: 1, y: -1))
    }

    func test3() {
        XCTAssertEqual(surroundingCoordinates(of: .zero), [
            Point(x: -1, y: 1),  Point(x: 0, y: 1),  Point(x: 1, y: 1),
            Point(x: -1, y: 0),                      Point(x: 1, y: 0),
            Point(x: -1, y: -1), Point(x: 0, y: -1), Point(x: 1, y: -1)
        ])
    }

    func test4() {
        XCTAssertEqual(firstValue(largerThan: 1), 2)
        XCTAssertEqual(firstValue(largerThan: 2), 4)
        XCTAssertEqual(firstValue(largerThan: 4), 5)
        XCTAssertEqual(firstValue(largerThan: 5), 10)
        XCTAssertEqual(firstValue(largerThan: 10), 11)
        XCTAssertEqual(firstValue(largerThan: 11), 23)
        XCTAssertEqual(firstValue(largerThan: 23), 25)
        XCTAssertEqual(firstValue(largerThan: 25), 26)
        XCTAssertEqual(firstValue(largerThan: 26), 54)
        XCTAssertEqual(firstValue(largerThan: 54), 57)
        XCTAssertEqual(firstValue(largerThan: 57), 59)
        XCTAssertEqual(firstValue(largerThan: 59), 122)
        XCTAssertEqual(firstValue(largerThan: 122), 133)
        XCTAssertEqual(firstValue(largerThan: 133), 142)
        XCTAssertEqual(firstValue(largerThan: 142), 147)
        XCTAssertEqual(firstValue(largerThan: 147), 304)
        XCTAssertEqual(firstValue(largerThan: 304), 330)
    }
}

GridSumTests.defaultTestSuite.run()

firstValue(largerThan: 289326)

