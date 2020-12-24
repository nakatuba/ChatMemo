//
//  CustomMessagesCollectionView.swift
//  ChatMemo
//
//  Created by 中川翼 on 2020/12/24.
//  Copyright © 2020 中川翼. All rights reserved.
//

import MessageKit

protocol CustomMessagesCollectionViewDelegate {
    func didTap()
}

class CustomMessagesCollectionView: MessagesCollectionView {
    
    var customMessagesCollectionViewDelegate: CustomMessagesCollectionViewDelegate?
    
    override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        if gesture.state == .ended {
            customMessagesCollectionViewDelegate?.didTap()
        }
        super.handleTapGesture(gesture)
    }
    
}
