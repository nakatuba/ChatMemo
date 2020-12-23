//
//  SavedMessage.swift
//  ChatMemo
//
//  Created by 中川翼 on 2020/12/15.
//  Copyright © 2020 中川翼. All rights reserved.
//

import RealmSwift

class SavedMessage: Object {
    @objc dynamic var text: String?
    @objc dynamic var image: Data?
    @objc dynamic var date: Date = Date()
    @objc dynamic var strikethrough = false
}
