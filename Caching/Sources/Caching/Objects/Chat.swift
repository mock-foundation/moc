//
//  Chat.swift
//  
//
//  Created by Егор Яковенко on 29.05.2022.
//

import RealmSwift

public class Chat: Object {
    @Persisted var title: String
    @Persisted var id: Int64
    @Persisted var lastMessage: String
    @Persisted var draftMessage: String
}
