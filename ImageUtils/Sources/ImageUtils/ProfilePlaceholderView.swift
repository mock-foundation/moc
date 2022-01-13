//
//  ProfilePlaceholderView.swift
//  
//
//  Created by Егор Яковенко on 12.01.2022.
//

import SwiftUI

public struct ProfilePlaceholderView: View {
    @State var userId: Int64
    @State var firstName: String
    @State var lastName: String
    @State var style: PlaceholderStyle

    public init(
        userId: Int64,
        firstName: String,
        lastName: String,
        style: PlaceholderStyle = .normal
    ) {
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.style = style
    }

    public var body: some View {
        ZStack {
            if lastName.isEmpty {
                Text("\(String(firstName.prefix(1)))")
                    .font(style == .normal ? .largeTitle : .system(size: 130, design: .rounded))
            } else {
                Text("\(String(firstName.prefix(1))) \(String(lastName.prefix(1)))")
                    .font(style == .normal ? .largeTitle : .system(size: 130, design: .rounded))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(fromUserId: userId))
    }
}

struct ProfilePlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePlaceholderView(userId: 736211268, firstName: "Андрей", lastName: "Shooting at Knee", style: .large)
    }
}
