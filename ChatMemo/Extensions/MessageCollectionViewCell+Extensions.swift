//
//  MessageCollectionViewCell+Extensions.swift
//  ChatMemo
//
//  Created by 中川翼 on 2020/12/23.
//  Copyright © 2020 中川翼. All rights reserved.
//

import MessageKit

extension MessageCollectionViewCell {
    
    @objc func editMessage(_ sender: Any?) {
        if let collectionView = superview as? UICollectionView,
           let indexPath = collectionView.indexPath(for: self) {
            collectionView.delegate?.collectionView?(collectionView,
                                                     performAction: NSSelectorFromString("editMessage:"),
                                                     forItemAt: indexPath,
                                                     withSender: sender)
        }
    }
    
    @objc func drawStrikethrough(_ sender: Any?) {
        if let collectionView = superview as? UICollectionView,
           let indexPath = collectionView.indexPath(for: self) {
            collectionView.delegate?.collectionView?(collectionView,
                                                     performAction: NSSelectorFromString("drawStrikethrough:"),
                                                     forItemAt: indexPath,
                                                     withSender: sender)
        }
    }
    
    @objc func copyMessage(_ sender: Any?) {
        if let collectionView = superview as? UICollectionView,
           let indexPath = collectionView.indexPath(for: self) {
            collectionView.delegate?.collectionView?(collectionView,
                                                     performAction: NSSelectorFromString("copyMessage:"),
                                                     forItemAt: indexPath,
                                                     withSender: sender)
        }
    }
    
    @objc func deleteMessage(_ sender: Any?) {
        if let collectionView = superview as? UICollectionView,
           let indexPath = collectionView.indexPath(for: self) {
            collectionView.delegate?.collectionView?(collectionView,
                                                     performAction: NSSelectorFromString("deleteMessage:"),
                                                     forItemAt: indexPath,
                                                     withSender: sender)
        }
    }
    
}
