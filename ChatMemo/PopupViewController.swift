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
    
    let topBorder = CALayer()
    let centerBorder = CALayer()
    var messageIndex = 0
    var messageText = ""
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popupView.layer.cornerRadius = 10
        textView.text = messageText
        textView.layer.cornerRadius = 10
        topBorder.backgroundColor = UIColor.secondaryLabel.cgColor
        cancelButton.layer.addSublayer(topBorder)
        centerBorder.backgroundColor = UIColor.secondaryLabel.cgColor
        cancelButton.layer.addSublayer(centerBorder)
        textView.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        topBorder.frame = CGRect(x: 0, y: 0, width: popupView.frame.size.width, height: 0.4)
        centerBorder.frame = CGRect(x: cancelButton.frame.size.width, y: 0, width: 0.4, height: cancelButton.frame.size.height)
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
        chatVC.scrollsToBottomOnKeyboardBeginsEditing = true
        chatVC.maintainPositionOnKeyboardFrameChanged = true
    }
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        let naviVC = presentingViewController as! UINavigationController
        let mainVC = naviVC.viewControllers[0] as! MainViewController
        let chatVC = mainVC.children[0] as! ChatViewController
        
        dismiss(animated: true, completion: nil)
        chatVC.scrollsToBottomOnKeyboardBeginsEditing = true
        chatVC.maintainPositionOnKeyboardFrameChanged = true
    }
    
}
