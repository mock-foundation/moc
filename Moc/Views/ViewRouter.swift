//
//  ViewRouter.swift
//  Moc
//
//  Created by Егор Яковенко on 06.01.2022.
//

import SwiftUI
import TDLibKit

final class ViewRouter: ObservableObject {
    public enum Views: CaseIterable {
        case selectChat
        case chat
    }
    @Published var viewParams: [Any?] = []
    @Published var currentView: Views = .selectChat
}
