//
//  ViewRouter.swift
//  Moc
//
//  Created by Егор Яковенко on 06.01.2022.
//

import SwiftUI
import TDLibKit

/// A simple view router for managing open chat state. Is **not** designed for more.
final class ViewRouter: ObservableObject {
    public enum Views: CaseIterable {
        case selectChat
        case chat
    }

    @Published var openedChat: Chat?
    @Published var currentView: Views = .selectChat
}
