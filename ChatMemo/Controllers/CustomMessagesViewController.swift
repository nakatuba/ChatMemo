//
//  CustomMessagesViewController.swift
//  ChatMemo
//
//  Created by 中川翼 on 2020/12/24.
//  Copyright © 2020 中川翼. All rights reserved.
//

import MessageKit

class CustomMessagesViewController: MessagesViewController {
    
    var customMessagesCollectionView = CustomMessagesCollectionView()
    
    override var messagesCollectionView: MessagesCollectionView {
        get {
            return customMessagesCollectionView
        }
        set {
            customMessagesCollectionView = newValue as! CustomMessagesCollectionView
        }
    }
    
}
