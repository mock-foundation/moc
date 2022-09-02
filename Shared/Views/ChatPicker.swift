//
//  ChatPicker.swift
//  Moc
//
//  Created by Егор Яковенко on 02.06.2022.
//

import SwiftUI

// TODO: Implement ChatPicker
struct ChatPicker: View {
    var body: some View {
        VStack {
            SearchField()
                .controlSize(.large)
            List {
                
            }
        }
    }
}

struct ChatPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ChatPicker()
    }
}
