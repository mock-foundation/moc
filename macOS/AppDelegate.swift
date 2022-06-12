//
//  AppDelegate.swift
//  Moc
//
//  Created by Егор Яковенко on 13.01.2022.
//

#if os(macOS)
import AppKit
import Resolver
import TDLibKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private func applicationWillTerminate(_: NSNotification) {
        TdApi.shared[0].client.close()
    }
}
#endif
