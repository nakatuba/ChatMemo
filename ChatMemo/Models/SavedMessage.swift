//
//  SavedMessage.swift
//  ChatMemo
//
//  Created by 中川翼 on 2020/12/15.
//  Copyright © 2020 中川翼. All rights reserved.
//

import RealmSwift

class SavedMessage: Object {
    @objc dynamic var text: String? = nil
    @objc dynamic var image: Data? = nil
    @objc dynamic var date: Date! = nil
}
