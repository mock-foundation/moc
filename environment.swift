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

enum ScriptError: Error {
    case parseError(String)
    case runCommandFail(String)
}

enum UserChoice {
    case yes
    case no
}

struct EnvironmentScript: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "environment.swift",
        abstract: "This script will set up (and tear down) the development environment by downloading all dependencies and generating all code."
    )
    
    @Argument(help: "Your API ID from my.telegram.org.")
    var apiId: Int?
    
    @Argument(help: "Your API hash from my.telegram.org.")
    var apiHash: String?
    
    @Flag(help: "Pass this argument if you want to tear down the environment")
    var teardown: Bool = false
    
    func run() throws {
        print() // a new line just in case
        print(projectNameText.white.bold)
        print()
        
        if teardown {
            logWarning("This task can remove swiftformat, swiftlint, gyb, swiftgen, and sourcery Homebrew packages.")
            logWarning("It can also clear all generated code.")
            
            if askForContinuation(
                "You really want to tear down the environment?",
                explicit: true,
                preferred: .no
            ) {
                if askForContinuation("Do you want to remove Homebrew packages related to Moc?") {
                    sectionStart("Homebrew output")
                    try run(command: "brew", with: ["remove", "swiftformat"])
                    try run(command: "brew", with: ["remove", "swiftlint"])
                    try run(command: "brew", with: ["remove", "gyb"])
                    try run(command: "brew", with: ["remove", "swiftgen"])
                    try run(command: "brew", with: ["remove", "sourcery"])
                    sectionEnd()
                }
                
                if askForContinuation("Do you want to clear generated code?") {
                    logInfo("Clearing generated code...")
                    try run(command: "rm", with: ["-rf", "Sources/Utilities/Generated"])
                    try run(command: "rm", with: ["-rf", "Moc/Generated"])
                }
                
                logOk("Finished!")
            } else {
                logOk("Ok, aborting!")
            }
        } else {
            if let apiId, let apiHash {
                logInfo("Installing dependencies...")
                try install(command: "swiftlint", from: "swiftlint", as: "SwiftLint")
                try install(command: "gyb", from: "ggoraa/apps/gyb", as: "GYB")
                try install(command: "swiftgen", from: "swiftgen", as: "SwiftGen")
                try install(command: "sourcery", from: "sourcery", as: "Sourcery")
                
                logInfo("Running GYB...")
                
                try FileManager.default.createDirectory(
                    atPath: "Utilities/Sources/Utilities/Generated",
                    withIntermediateDirectories: true)
                
                
                logError("Not implemented")
            } else {
                logError("Not enought arguments supplied, please check if you did insert API ID and hash values.")
            }
        }
    }
    
    func envValue(for key: String) -> String? {
        ProcessInfo.processInfo.environment[key]
    }
    
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
    
    func logNotice(_ message: String) {
        log(message.cyan)
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
        if try runWithOutput(command: "which", with: [command]).contains(command) {
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
    func runWithOutput(command: String, with args: [String]) throws -> String {
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
    
    /// Runs a supplied shell command.
    /// - Parameters:
    ///   - command: A command to run.
    ///   - args: Args supplied to it
    /// - Throws: Any error, like being unable to parse command's response or a run failure.
    /// - Returns: Command's output
    @discardableResult
    func run(pwd: String? = nil, command: String, with args: [String]) throws -> Int32 {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = [command] + args
        if let pwd {
            task.currentDirectoryURL = URL(string: pwd)!
        }
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus
    }
    
    /// Runs `readLine()` that asks the user for `y` or `n` response.
    /// - Parameter message: The message with the request.
    /// - Parameter explicit: Whether to explicitly ask for `yes` or `no` response.
    /// - Returns: User's choice
    func askForContinuation(_ message: String, explicit: Bool = false, preferred: UserChoice = .yes) -> Bool {
        // This mess is just a system for lighting the choices in different ways
        print(
            message.bold.underline + " "
            + (explicit
               ? "(" + (preferred == .yes
                        ? "yes".green
                        : "yes".lightRed)
               + "/" + (preferred == .no
                        ? "no".green
                        : "no".lightRed) + ")"
               : "(" + (preferred == .yes
                        ? "Y".green
                        : "Y".lightRed) + "/"
               + (preferred == .no
                  ? "n".green
                  : "n".lightRed) + ")")
            + " ", terminator: "")
        
        if let result = readLine() {
            switch result.lowercased() {
                case "y":
                    if explicit {
                        print()
                        logNotice("Please write a full answer:")
                        askForContinuation(message, explicit: explicit, preferred: preferred)
                    } else {
                        return true
                    }
                case "yes":
                    return true
                case "n":
                    if explicit {
                        logNotice("Please write a full answer:")
                        askForContinuation(message, explicit: explicit, preferred: preferred)
                    } else {
                        return false
                    }
                case "no":
                    return false
                default:
                    logNotice("Wrong response. Please try again:")
                    askForContinuation(message, explicit: explicit, preferred: preferred)
            }
        } else {
            logError("Unable to ask for continuation.")
        }
        
        return false
    }
}

EnvironmentScript.main()
