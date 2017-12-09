import Foundation

let inputURL = Bundle.main.url(forResource: "input", withExtension: "txt")!
let input = try! String(contentsOf: inputURL, encoding: .utf8)
    .components(separatedBy: .newlines)
    .filter { !$0.isEmpty }
    .sorted { $0.count < $1.count }

// The name of the bottom program won't have any pointers to it
var names = input.flatMap { $0.components(separatedBy: .whitespaces).first }
var pointers = input.flatMap { line -> [String] in
    let components = line.components(separatedBy: "-> ")
    if components.count > 1 { return components[1].components(separatedBy: ", ") }
    else { return [] }
}

Set(names).subtracting(Set(pointers))
