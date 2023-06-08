//
//  ProfilePlaceholderView.swift
//
//
//  Created by Егор Яковенко on 12.01.2022.
//

import SwiftUI

struct ProfilePlaceholderView: View {
    @State var userId: Int64
    @State var firstName: String
    @State var lastName: String
    @State var style: PlaceholderStyle = .normal
    
    var content: some View {
        ZStack {
            Group {
                if lastName.isEmpty {
                    Text("\(String(firstName.prefix(1)))")
                } else {
                    Text("\(String(firstName.prefix(1))) \(String(lastName.prefix(1)))")
                }
            }
            .font(style.font)
            .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var body: some View {
        content
            .background(Color(fromUserId: userId).gradient)
    }
}

struct ProfilePlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePlaceholderView(userId: 736211268, firstName: "Андрей", lastName: "Shooting at Knee", style: .normal)
            .frame(width: 100, height: 100)
            .clipShape(Circle())
    }
}
