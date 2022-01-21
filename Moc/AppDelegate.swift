//
//  AppDelegate.swift
//  Moc
//
//  Created by Егор Яковенко on 13.01.2022.
//

import AppKit
import Resolver
import TDLibKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private func applicationWillTerminate(_ notification: NSNotification) {
        TdApi.shared[0].client.close()
    }
}
