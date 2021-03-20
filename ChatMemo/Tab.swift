//
//  Tab.swift
//  ChatMemo
//
//  Created by 中川翼 on 2020/02/09.
//  Copyright © 2020 中川翼. All rights reserved.
//

import UIKit
import RealmSwift

class Tab: Object {
    @objc dynamic var name = ""
    let savedMessageList = List<SavedMessage>()
}

class SavedMessage: Object {
    @objc dynamic var text: String? = nil
    @objc dynamic var image: Data? = nil
    @objc dynamic var date: Date! = nil
}
