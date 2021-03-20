//
//  EditViewController.swift
//  ChatMemo
//
//  Created by 中川翼 on 2020/05/04.
//  Copyright © 2020 中川翼. All rights reserved.
//

import UIKit
import RealmSwift

class PopupViewController: UIViewController {

    var messageIndex = 0
    var messageText = ""
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = messageText
        textView.layer.cornerRadius = 10
        textView.becomeFirstResponder()
    }
    
    @IBAction func didTapChangeButton(_ sender: Any) {
        let naviVC = presentingViewController as! UINavigationController
        let mainVC = naviVC.viewControllers[0] as! MainViewController
        let chatVC = mainVC.children[0] as! ChatViewController
        let realm = try! Realm()
        let tabObjects = realm.objects(Tab.self)
        
        guard let text = textView.text, !text.isEmpty else { return }
        try! realm.write {
            tabObjects[chatVC.tabIndex].savedMessageList[messageIndex].text = text
        }
        chatVC.messageList[messageIndex] = MockMessage(
            text: text,
            user: MockUser(senderId: "", displayName: ""),
            messageId: UUID().uuidString,
            date: tabObjects[chatVC.tabIndex].savedMessageList[messageIndex].date)
        chatVC.messagesCollectionView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
