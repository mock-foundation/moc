#!/usr/bin/env swift sh

//
// This script will set up development environment. Much wow.
//

import Foundation

import Rainbow // @onevcat ~> 4.0
import ArgumentParser // apple/swift-argument-parser ~> 1.0.0

let projectNameText = """
     /$$      /$$
    | $$$    /$$$
    | $$$$  /$$$$  /$$$$$$   /$$$$$$$
    | $$ $$/$$ $$ /$$__  $$ /$$_____/
    | $$  $$$| $$| $$  \\ $$| $$
    | $$\\  $ | $$| $$  | $$| $$
    | $$ \\/  | $$|  $$$$$$/|  $$$$$$$
    |__/     |__/ \\______/  \\_______/
"""


print() // a new line just in case

print(projectNameText.white.bold)

print("\n  This script will set up (and tear down) the development environment by downloading all dependencies and generating all code.\n".white)

func log(_ message: String) {
    print(">>> ".white.bold + message.bold)
}

func logInfo(_ message: String) {
    log(message.blue)
}

func logOk(_ message: String) {
    log(message.green)
}

func logWarning(_ message: String) {
    log(message.yellow)
}

func logError(_ message: String) {
    log(message.red)
}

func sectionStart(_ message: String) {
    print("\n" + "--- ".white.bold + message.white.bold + " ---".white.bold + "\n")
}

func sectionEnd() {
    print("\n------\n".white.bold)
}

/// Installs a specified command if not available
/// - Parameters:
///   - command: Command to be installed
///   - brew: Name of the command in Homebrew
///   - display: How this command's name is displayed in logs
func install(command: String, from brew: String, as display: String) throws {
    if try run(command: "which", with: [command]).contains(command) {
        logOk("\(display) is installed")
    } else {
        logInfo("\(display) was not found, installing...")
        sectionStart("Homebrew output")
        try run(command: "brew", with: ["install", brew])
        sectionEnd()
    }
}

/// Runs a supplied shell command.
/// - Parameters:
///   - command: A command to run.
///   - args: Args supplied to it
/// - Throws: Any error, like being unable to parse command's response or a run failure.
/// - Returns: Command's output
@discardableResult
func run(command: String, with args: [String]) throws -> String {
    let which = Process()
    which.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    which.arguments = [command] + args

    var pipe = Pipe()
    which.standardOutput = pipe

    do {
        try which.run()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
            return output
        } else {
            throw ScriptError.parseError("Unable to parse '\(command)' command's output")
        }
    } catch {
        throw ScriptError.runCommandFail("Unable to run command \(command)")
    }
}

try install(command: "swiftlint", from: "swiftlint", as: "SwiftLint")

enum ScriptError: Error {
    case parseError(String)
    case runCommandFail(String)
}
