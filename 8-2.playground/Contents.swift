import Foundation

typealias Register = String
typealias Registers = [Register: Int]

struct Instruction: Equatable {
    let register: Register
    let mutation: Mutation
    let condition: Condition

    func perform(with registers: Registers) -> Registers {
        if condition.evaluate(against: registers) {
            var newRegisters = registers
            newRegisters[register] = mutation.mutate(value: registers[register, default: 0])
            return newRegisters
        }
        else {
            return registers
        }
    }

    static func == (lhs: Instruction, rhs: Instruction) -> Bool {
        return lhs.register == rhs.register &&
               lhs.mutation == rhs.mutation &&
               lhs.condition == rhs.condition
    }
}

extension Instruction {
    /// Expects a string of the form "REGISTER MUTATION AMOUNT if REGISTER OPERATOR VALUE"
    init?(description: String) {
        let components = description.components(separatedBy: .whitespaces)
        guard
            components.count == 7,
            let mutation = Mutation(description: components[1..<3].joined(separator: " ")),
            let condition = Condition(description: components[3..<7].joined(separator: " "))
        else { return nil }

        register = components[0]
        self.mutation = mutation
        self.condition = condition
    }
}

enum Mutation: Equatable {
    case increment(amount: Int)
    case decrement(amount: Int)

    func mutate(value: Int) -> Int {
        switch self {
        case let .increment(amount):
            return value + amount
        case let .decrement(amount):
            return value - amount
        }
    }

    static func == (lhs: Mutation, rhs: Mutation) -> Bool {
        switch (lhs, rhs) {
        case let (.increment(left), .increment(right)):
            return left == right
        case let (.decrement(left), .decrement(right)):
            return left == right
        default:
            return false
        }
    }
}

extension Mutation {
    /// Expects a string of the form "MUTATION AMOUNT"
    init?(description: String) {
        let components = description.components(separatedBy: .whitespaces)
        guard
            components.count == 2,
            let amount = Int(components[1])
        else { return nil }

        switch components[0] {
        case "inc":
            self = .increment(amount: amount)
        case "dec":
            self = .decrement(amount: amount)
        default:
            return nil
        }
    }
}

struct Condition: Equatable {
    let register: Register
    /// operator is a keyword, so I'm using op to avoid the need for backticks everywhere
    let op: Operator
    let value: Int

    func evaluate(against registers: Registers) -> Bool {
        switch op {
        case .lessThan:
            return registers[register, default: 0] < value
        case .lessThanOrEqualTo:
            return registers[register, default: 0] <= value
        case .equalTo:
            return registers[register, default: 0] == value
        case .notEqualTo:
            return registers[register, default: 0] != value
        case .greaterThanOrEqualTo:
            return registers[register, default: 0] >= value
        case .greaterThan:
            return registers[register, default: 0] > value
        }
    }

    static func == (lhs: Condition, rhs: Condition) -> Bool {
        return lhs.register == rhs.register &&
               lhs.op == rhs.op &&
               lhs.value == rhs.value
    }
}

extension Condition {
    /// Expects a string of the form "if REGISTER OPERATOR VALUE"
    init?(description: String) {
        let components = description.components(separatedBy: .whitespaces)
        guard
            components.count == 4,
            let op = Operator(rawValue: components[2]),
            let value = Int(components[3])
        else { return nil }

        register = components[1]
        self.op = op
        self.value = value
    }
}

enum Operator: String {
    case lessThan = "<"
    case lessThanOrEqualTo = "<="
    case equalTo = "=="
    case notEqualTo = "!="
    case greaterThanOrEqualTo = ">="
    case greaterThan = ">"
}

expect(Instruction(description: "b inc 5 if a > 1")).to(equal(
    Instruction(
        register: "b",
        mutation: .increment(amount: 5),
        condition: Condition(register: "a", op: .greaterThan, value: 1))))

typealias State = (registers: Registers, highestRunningValue: Int)

func interpret(program: String) -> State {
    let descriptions = program.components(separatedBy: .newlines)
    let instructions = descriptions.flatMap(Instruction.init(description:))
    let initialState = (registers: Registers(), highestRunningValue: 0)
    return instructions.reduce(initialState) { value, instruction in
        let newRegisters = instruction.perform(with: value.registers)
        return (
            registers: newRegisters,
            highestRunningValue: max(value.highestRunningValue, newRegisters.values.max() ?? 0)
        )
    }
}

let example = """
b inc 5 if a > 1
a inc 1 if b < 5
c dec -10 if a >= 1
c inc -20 if c == 10
"""

expect(interpret(program: example).registers.values.max()).to(equal(1))

let inputURL = Bundle.main.url(forResource: "input", withExtension: "txt")!
let input = try! String(contentsOf: inputURL)
interpret(program: input).highestRunningValue
