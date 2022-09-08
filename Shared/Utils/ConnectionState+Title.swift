//
//  ConnectionState+Title.swift
//  Moc
//
//  Created by Егор Яковенко on 08.09.2022.
//

import TDLibKit

extension ConnectionState {
    var title: String {
        switch self {
            case .waitingForNetwork:
                return "Waiting for network..."
            case .connectingToProxy:
                return "Connecting to proxy..."
            case .connecting:
                return "Connecting..."
            case .updating:
                return "Updating..."
            case .ready:
                return "Connected!"
        }
    }
}
