#!/usr/bin/env swift sh

import Rainbow // @onevcat ~> 4.0

func log(_ message: String) {
    print(">>> ".white.bold + message.bold)
}

func info(_ message: String) {
    log(message.blue)
}

func ok(_ message: String) {
    log(message.green)
}

func warning(_ message: String) {
    log(message.yellow)
}

func error(_ message: String) {
    log(message.red)
}

func sectionStart(_ message: String) {
    print("\n" + "--- ".white.bold + message.white.bold + " ---".white.bold + "\n")
}

func sectionEnd() {
    print("\n------\n".white.bold)
}
