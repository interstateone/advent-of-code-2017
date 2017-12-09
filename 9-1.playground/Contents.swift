import Foundation

enum Mode {
    case normal
    case garbage
    case ignoring
}

typealias GarbageState = (mode: Mode, output: String)

func filterGarbage(state: GarbageState, character: Character) -> GarbageState {
    switch character {
    case "<":
        switch state.mode {
        case .normal:
            return (mode: .garbage, output: state.output)
        case .garbage:
            return state
        case .ignoring:
            return (mode: .garbage, output: state.output)
        }
    case ">":
        switch state.mode {
        case .normal:
            return (mode: .garbage, output: state.output.appending(String(character)))
        case .garbage:
            return (mode: .normal, output: state.output)
        case .ignoring:
            return (mode: .garbage, output: state.output)
        }
    case "!":
        switch state.mode {
        case .normal:
            return (mode: .normal, output: state.output.appending(String(character)))
        case .garbage:
            return (mode: .ignoring, output: state.output)
        case .ignoring:
            return (mode: .garbage, output: state.output)
        }
    default:
        switch state.mode {
        case .normal:
            return (mode: .normal, output: state.output.appending(String(character)))
        case .garbage:
            return state
        case .ignoring:
            return (mode: .garbage, output: state.output)
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
    return stream.reduce(GarbageState(mode: .normal, output: ""), filterGarbage).output
}

expect(dropGarbage(from: "<>")).to(equal(""))
expect(dropGarbage(from: "<asdfasdfasdf>")).to(equal(""))
expect(dropGarbage(from: "<<<<>")).to(equal(""))
expect(dropGarbage(from: "<{!>}>")).to(equal(""))
expect(dropGarbage(from: "<!!>")).to(equal(""))
expect(dropGarbage(from: "<!!!>>")).to(equal(""))
expect(dropGarbage(from: "<{o\"i!a,<{i<a>")).to(equal(""))

func value(of stream: String) -> Int {
    return dropGarbage(from: stream).reduce(GroupState(level: 0, score: 0)) { state, character in
        switch character {
        case "{":
            return GroupState(level: state.level + 1, score: state.score)
        case "}":
            return GroupState(level: state.level - 1, score: state.score + state.level)
        default:
            return state
        }
    }.score
}

expect(value(of: "{}")).to(equal(1))
expect(value(of: "{{{}}}")).to(equal(6))
expect(value(of: "{{},{}}")).to(equal(5))
expect(value(of: "{{{},{},{{}}}}")).to(equal(16))
expect(value(of: "{<a>,<a>,<a>,<a>}")).to(equal(1))
expect(value(of: "{{<ab>},{<ab>},{<ab>},{<ab>}}")).to(equal(9))
expect(value(of: "{{<!!>},{<!!>},{<!!>},{<!!>}}")).to(equal(9))
expect(value(of: "{{<a!>},{<a!>},{<a!>},{<ab>}}")).to(equal(3))

let inputURL = Bundle.main.url(forResource: "input", withExtension: "txt")!
let input = try! String(contentsOf: inputURL)
value(of: input)
