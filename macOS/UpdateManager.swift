//
//  UpdateManager.swift
//  Moc
//
//  Created by Егор Яковенко on 02.08.2022.
//

import Combine
import Sparkle
import Utilities
import AppCenterAnalytics

class UpdateManager: ObservableObject {
    private let updaterController: SPUStandardUpdaterController
    
    @Published var canCheckForUpdates = false
    
    init() {
        // If you want to start the updater manually, pass false to startingUpdater and call .startUpdater() later
        // This is where you can also pass an updater delegate if you need one
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil)
        
        updaterController.updater.checkForUpdatesInBackground()
        
        updaterController.updater.setFeedURL(
            URL(string: "https://api.appcenter.ms/v0.1/public/sparkle/apps/\(Secret.appCenterSecret)"))
        
        updaterController.updater.publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
    }
    
    func checkForUpdates() {
        Analytics.trackEvent("Manually checked for updates")
        updaterController.checkForUpdates(nil)
    }
}
