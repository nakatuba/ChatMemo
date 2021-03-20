//
//  ChatViewController.swift
//  ChatMemo
//
//  Created by 中川翼 on 2020/02/07.
//  Copyright © 2020 中川翼. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import RealmSwift
import XLPagerTabStrip
import SKPhotoBrowser

class ChatViewController: MessagesViewController, IndicatorInfoProvider, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

    var tabIndex = 0
    var messageList: [MockMessage] = []
    var images = [SKPhoto]()
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        let realm = try! Realm()
        let tabObjects = realm.objects(Tab.self)
        return IndicatorInfo(title: tabObjects[tabIndex].name)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.backgroundColor = UIColor(red: 120/255, green: 180/255, blue: 240/255, alpha: 1)
        messageInputBar.delegate = self
        messageInputBar.inputTextView.textColor = .black
        messageInputBar.inputTextView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        messageInputBar.inputTextView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        messageInputBar.inputTextView.layer.borderWidth = 1.0
        messageInputBar.inputTextView.layer.cornerRadius = 20.0
        messageInputBar.sendButton.title = "送信"
        
        let cameraButton = makeButton(systemName: "camera")
        cameraButton.onTouchUpInside { _ in
            let pickerController = UIImagePickerController()
            pickerController.sourceType = .camera
            pickerController.delegate = self
            self.present(pickerController, animated: true, completion: nil)
        }
        
        let photoButton = makeButton(systemName: "photo")
        photoButton.onTouchUpInside { _ in
            let pickerController = UIImagePickerController()
            pickerController.sourceType = .savedPhotosAlbum
            pickerController.delegate = self
            self.present(pickerController, animated: true, completion: nil)
        }
        
        let items = [cameraButton, photoButton, .flexibleSpace]
        messageInputBar.setStackViewItems(items, forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 76, animated: false)
        
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.setMessageOutgoingAvatarSize(.zero)
            let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
            layout.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: insets))
            layout.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: insets))
        }
        
        let realm = try! Realm()
        let tabObjects = realm.objects(Tab.self)
        for savedMessage in tabObjects[tabIndex].savedMessageList {
            insertMessage(text: savedMessage.text, image: savedMessage.image, date: savedMessage.date)
        }
        messagesCollectionView.layoutIfNeeded()
        messagesCollectionView.contentOffset.y = messagesCollectionView.contentSize.height
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        tapGesture.delegate = self
        messagesCollectionView.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if messagesCollectionView.contentSize.height - messagesCollectionView.frame.size.height - (messagesCollectionView.cellForItem(at: IndexPath(row: 0, section: messageList.count - 1))?.frame.size.height ?? 0) < messagesCollectionView.contentOffset.y {
            scrollsToBottomOnKeyboardBeginsEditing = true
            maintainPositionOnKeyboardFrameChanged = true
        } else {
            scrollsToBottomOnKeyboardBeginsEditing = false
            maintainPositionOnKeyboardFrameChanged = false
        }
    }
    
    func insertMessage(text: String?, image: Data?, date: Date) {
        let user = MockUser(senderId: "", displayName: "")
        
        if let text = text {
            let message = MockMessage(text: text,  user: user, messageId: UUID().uuidString, date: date)
            messageList.append(message)
        } else if let data = image, let image = UIImage(data: data) {
            let message = MockMessage(image: image,  user: user, messageId: UUID().uuidString, date: date)
            messageList.append(message)
            let photo = SKPhoto.photoWithImage(image)
            images.append(photo)
        }
        
        messagesCollectionView.reloadData()
    }
    
    func isDateLabelVisible(at indexPath: IndexPath) -> Bool {
        let realm = try! Realm()
        let tabObjects = realm.objects(Tab.self)
        
        var lastMessageDate = ""
        var thisMessageDate = ""
        
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        
        if tabIndex < tabObjects.count {
            if indexPath.section > 0, indexPath.section - 1 < tabObjects[tabIndex].savedMessageList.count {
                lastMessageDate = formatter.string(from: tabObjects[tabIndex].savedMessageList[indexPath.section - 1].date)
            }
            
            if indexPath.section < tabObjects[tabIndex].savedMessageList.count {
                thisMessageDate = formatter.string(from: tabObjects[tabIndex].savedMessageList[indexPath.section].date)
            }
        }
        
        return lastMessageDate != thisMessageDate
    }
    
    func makeButton(systemName: String) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(10)
                $0.image = UIImage(systemName: systemName)?.withRenderingMode(.alwaysTemplate)
                $0.setSize(CGSize(width: 25, height: 40), animated: false)
                $0.tintColor = UIColor(red: 0/255, green: 30/255, blue: 60/255, alpha: 1)
            }.onSelected {
                $0.tintColor = .lightGray
            }.onDeselected {
                $0.tintColor = UIColor(red: 0/255, green: 30/255, blue: 60/255, alpha: 1)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])  {
        if let image = info[.originalImage] as? UIImage, let cgImage = image.cgImage {
            let scale = image.size.width / (messageInputBar.inputTextView.frame.width - 2 * (messageInputBar.inputTextView.textContainerInset.left + messageInputBar.inputTextView.textContainerInset.right))
            let textAttachment = NSTextAttachment()
            textAttachment.image = UIImage(cgImage: cgImage, scale: scale, orientation: image.imageOrientation)
            let attributedImageString = NSAttributedString(attachment: textAttachment)
            let isEmpty = messageInputBar.inputTextView.attributedText.length == 0
            let newAttributedStingComponent = isEmpty ? NSMutableAttributedString(string: "") : NSMutableAttributedString(string: "\n")
            newAttributedStingComponent.append(attributedImageString)
            newAttributedStingComponent.append(NSAttributedString(string: "\n"))
            let attributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.font: messageInputBar.inputTextView.font ?? UIFont.preferredFont(forTextStyle: .body),
                NSAttributedString.Key.foregroundColor: messageInputBar.inputTextView.textColor ?? .black
            ]
            newAttributedStingComponent.addAttributes(attributes, range: NSRange(location: 0, length: newAttributedStingComponent.length))
            messageInputBar.inputTextView.textStorage.beginEditing()
            messageInputBar.inputTextView.textStorage.replaceCharacters(in: messageInputBar.inputTextView.selectedRange, with: newAttributedStingComponent)
            messageInputBar.inputTextView.textStorage.endEditing()
            let location = messageInputBar.inputTextView.selectedRange.location + (isEmpty ? 2 : 3)
            messageInputBar.inputTextView.selectedRange = NSRange(location: location, length: 0)
            NotificationCenter.default.post(name: UITextView.textDidChangeNotification, object: self)
            messageInputBar.sendButton.isEnabled = true
        }
        self.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer){
        if sender.state == .ended {
            messageInputBar.inputTextView.resignFirstResponder()
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer is UILongPressGestureRecognizer {
            return false
        }
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if action == NSSelectorFromString("delete:") {
            return true
        } else {
            return super.collectionView(collectionView, canPerformAction: action, forItemAt: indexPath, withSender: sender)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        if action == NSSelectorFromString("delete:") {
            let realm = try! Realm()
            let tabObjects = realm.objects(Tab.self)
            
            if tabObjects[tabIndex].savedMessageList[indexPath.section].image != nil {
                var imageIndex = 0
                for savedMessage in tabObjects[tabIndex].savedMessageList[0..<indexPath.section] {
                    if savedMessage.image != nil {
                        imageIndex += 1
                    }
                }
                images.remove(at: imageIndex)
            }
            
            let savedMessage = tabObjects[tabIndex].savedMessageList[indexPath.section]
            try! realm.write {
                realm.delete(savedMessage)
            }
            
            messageList.remove(at: indexPath.section)
            messagesCollectionView.reloadData()
        } else {
            super.collectionView(collectionView, performAction: action, forItemAt: indexPath, withSender: sender)
        }
    }

}

extension MessageCollectionViewCell {
    
    override open func delete(_ sender: Any?) {
        if let collectionView = self.superview as? UICollectionView {
            if let indexPath = collectionView.indexPath(for: self) {
                collectionView.delegate?.collectionView?(collectionView, performAction: NSSelectorFromString("delete:"), forItemAt: indexPath, withSender: sender)
            }
        }
    }
    
}

extension ChatViewController: MessagesDataSource {
    
    func currentSender() -> SenderType {
        return Sender(id: "", displayName: "")
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if isDateLabelVisible(at: indexPath) {
            switch true {
            case Calendar.current.isDateInToday(message.sentDate) || Calendar.current.isDateInYesterday(message.sentDate):
                formatter.doesRelativeDateFormatting = true
            case Calendar.current.isDate(message.sentDate, equalTo: Date(), toGranularity: .year):
                formatter.dateFormat = "M/d(E)"
            default:
                formatter.dateFormat = "y年M月d日(E)"
            }

            return NSAttributedString(string: formatter.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.white])
        }
        return nil
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2), NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
}

extension ChatViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isDateLabelVisible(at: indexPath) {
            return 32
        }
        return 0
    }

    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 8
    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
}

extension ChatViewController: MessagesDisplayDelegate {

    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return .black
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .url, .phoneNumber: return [.foregroundColor: UIColor.blue, .underlineStyle: NSUnderlineStyle.single.rawValue]
        default: return MessageLabel.defaultAttributes
        }
    }

    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .phoneNumber]
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }

}

extension ChatViewController: MessageCellDelegate {
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        messageInputBar.inputTextView.resignFirstResponder()
        if let collectionView = cell.superview as? UICollectionView {
            if let indexPath = collectionView.indexPath(for: cell) {
                let realm = try! Realm()
                let tabObjects = realm.objects(Tab.self)
                if tabObjects[tabIndex].savedMessageList[indexPath.section].image != nil {
                    var imageIndex = 0
                    for savedMessage in tabObjects[tabIndex].savedMessageList[0..<indexPath.section] {
                        if savedMessage.image != nil {
                            imageIndex += 1
                        }
                    }
                    let browser = SKPhotoBrowser(photos: images)
                    browser.initializePageIndex(imageIndex)
                    present(browser, animated: true, completion: {})
                }
            }
        }
    }
    
    func didSelectPhoneNumber(_ phoneNumber: String) {
        UIApplication.shared.open(URL(string: "tel:\(phoneNumber)")! as URL)
    }
    
    func didSelectURL(_ url: URL) {
        messageInputBar.inputTextView.resignFirstResponder()
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        var title = "Safariで開く"
        
        if url.scheme == "mailto" {
                title = "新規メッセージ"
        }
        
        let urlAction = UIAlertAction(title: title, style: .default, handler: { _ in
            UIApplication.shared.open(url)
            self.becomeFirstResponder()
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: { _ in
            self.becomeFirstResponder()
        })
        
        alert.addAction(urlAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
}

extension ChatViewController: MessageInputBarDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let components = inputBar.inputTextView.components
        
        for component in components {
            let savedMessage = SavedMessage()
            
            if let text = component as? String {
                savedMessage.text = text
            } else if let image = component as? UIImage {
                savedMessage.image = image.jpegData(compressionQuality: 1.0)
            }
            savedMessage.date = Date()
            
            let realm = try! Realm()
            let tabObjects = realm.objects(Tab.self)
            try! realm.write {
                tabObjects[tabIndex].savedMessageList.append(savedMessage)
            }
            
            insertMessage(text: savedMessage.text, image: savedMessage.image, date: savedMessage.date)
            messagesCollectionView.scrollToBottom(animated: true)
        }
        
        messageInputBar.inputTextView.text = ""
    }
    
}