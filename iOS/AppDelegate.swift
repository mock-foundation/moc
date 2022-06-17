//
//  AppDelegate.swift
//  Moc
//
//  Created by Егор Яковенко on 12.06.2022.
//

import UIKit
import TDLibKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func applicationWillTerminate(_ application: UIApplication) {
        TdApi.shared[0].client.close()
    }
}
