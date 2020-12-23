//
//  Tab.swift
//  ChatMemo
//
//  Created by 中川翼 on 2020/02/09.
//  Copyright © 2020 中川翼. All rights reserved.
//

import RealmSwift

class Tab: Object {
    @objc dynamic var name = ""
    @objc dynamic var order = 0
    let savedMessageList = List<SavedMessage>()
}
