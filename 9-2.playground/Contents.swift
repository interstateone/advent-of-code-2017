import Foundation

enum Mode {
    case normal
    case garbage
    case ignoring
}

typealias GarbageState = (mode: Mode, skipped: Int, output: String)

func filterGarbage(state: GarbageState, character: Character) -> GarbageState {
    switch character {
    case "<":
        switch state.mode {
        case .normal:
            return (mode: .garbage, skipped: state.skipped, output: state.output)
        case .garbage:
            return (mode: .garbage, skipped: state.skipped + 1, output: state.output)
        case .ignoring:
            return (mode: .garbage, skipped: state.skipped, output: state.output)
        }
    case ">":
        switch state.mode {
        case .normal:
            return (mode: .garbage, skipped: state.skipped, output: state.output.appending(String(character)))
        case .garbage:
            return (mode: .normal, skipped: state.skipped, output: state.output)
        case .ignoring:
            return (mode: .garbage, skipped: state.skipped, output: state.output)
        }
    case "!":
        switch state.mode {
        case .normal:
            return (mode: .normal, skipped: state.skipped, output: state.output.appending(String(character)))
        case .garbage:
            return (mode: .ignoring, skipped: state.skipped, output: state.output)
        case .ignoring:
            return (mode: .garbage, skipped: state.skipped, output: state.output)
        }
    default:
        switch state.mode {
        case .normal:
            return (mode: .normal, skipped: state.skipped, output: state.output.appending(String(character)))
        case .garbage:
            return (mode: .garbage, skipped: state.skipped + 1, output: state.output)
        case .ignoring:
            return (mode: .garbage, skipped: state.skipped, output: state.output)
        }
    }
}

typealias GroupState = (level: Int, score: Int)

func score(state: GroupState, character: Character) -> GroupState {
    switch character {
    case "{":
        return GroupState(level: state.level + 1, score: state.score)
    case "}":
        return GroupState(level: state.level - 1, score: state.score + state.level)
    default:
        return state
    }
}

func dropGarbage(from stream: String) -> String {
    return stream.reduce(GarbageState(mode: .normal, skipped: 0, output: ""), filterGarbage).output
}

expect(dropGarbage(from: "<>")).to(equal(""))
expect(dropGarbage(from: "<asdfasdfasdf>")).to(equal(""))
expect(dropGarbage(from: "<<<<>")).to(equal(""))
expect(dropGarbage(from: "<{!>}>")).to(equal(""))
expect(dropGarbage(from: "<!!>")).to(equal(""))
expect(dropGarbage(from: "<!!!>>")).to(equal(""))
expect(dropGarbage(from: "<{o\"i!a,<{i<a>")).to(equal(""))

func skippedGarbage(in stream: String) -> Int {
    return stream.reduce(GarbageState(mode: .normal, skipped: 0, output: ""), filterGarbage).skipped
}

expect(skippedGarbage(in: "<>")).to(equal(0))
expect(skippedGarbage(in: "<random characters>")).to(equal(17))
expect(skippedGarbage(in: "<<<<>")).to(equal(3))
expect(skippedGarbage(in: "<{!>}>")).to(equal(2))
expect(skippedGarbage(in: "<!!>")).to(equal(0))
expect(skippedGarbage(in: "<!!!>>")).to(equal(0))
expect(skippedGarbage(in: "<{o\"i!a,<{i<a>")).to(equal(10))

let inputURL = Bundle.main.url(forResource: "input", withExtension: "txt")!
let input = try! String(contentsOf: inputURL)
skippedGarbage(in: input)

