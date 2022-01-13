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
    @Injected var tdApi: TdApi

    private func applicationWillTerminate(_ notification: NSNotification) {
        tdApi.client.close()
    }
}
