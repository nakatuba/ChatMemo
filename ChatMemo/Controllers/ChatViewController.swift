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

class ChatViewController: CustomMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let realm = try! Realm()
    var savedMessageList: List<SavedMessage>!
    var currentTab: Tab! {
        didSet {
            savedMessageList = currentTab.savedMessageList
        }
    }
    
    var messageList: [MockMessage] {
        return savedMessageList.compactMap { savedMessage in
            let user = MockUser(senderId: "", displayName: "")
            let messageId = UUID().uuidString
            let date = savedMessage.date
            
            if let text = savedMessage.text {
                if savedMessage.strikethrough {
                    let attributes: [NSAttributedString.Key : Any] = [
                        .font : UIFont.preferredFont(forTextStyle: .body),
                        .strikethroughStyle : NSUnderlineStyle.thick.rawValue
                    ]
                    let attributedString = NSAttributedString(string: text, attributes: attributes)
                    
                    return MockMessage(attributedText: attributedString, user: user, messageId: messageId, date: date)
                }
                
                return MockMessage(text: text, user: user, messageId: messageId, date: date)
            } else if let data = savedMessage.image, let image = UIImage(data: data) {
                return MockMessage(image: image, user: user, messageId: messageId, date: date)
            }
            
            return nil
        }
    }
    
    var images: [SKPhoto] {
        return savedMessageList.compactMap { savedMessage in
            if let data = savedMessage.image, let image = UIImage(data: data) {
                return SKPhoto.photoWithImage(image)
            }
            
            return nil
        }
    }
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: NSLocalizedString("en_US", comment: ""))
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.backgroundColor = UIColor(red: 120/255, green: 180/255, blue: 240/255, alpha: 1)
        
        messageInputBar.delegate = self
        messageInputBar.backgroundView.backgroundColor = .white
        messageInputBar.inputTextView.textColor = .black
        messageInputBar.inputTextView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        messageInputBar.inputTextView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        messageInputBar.inputTextView.layer.borderWidth = 1.0
        messageInputBar.inputTextView.layer.cornerRadius = 20.0
        messageInputBar.sendButton.setImage(UIImage(named: "send"), for: .normal)
        
        customMessagesCollectionView.customMessagesCollectionViewDelegate = self
        
//        scrollsToBottomOnKeyboardBeginsEditing = true
//        maintainPositionOnKeyboardFrameChanged = true
        
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
        messageInputBar.setRightStackViewWidthConstant(to: 26, animated: false)
        
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.setMessageOutgoingAvatarSize(.zero)
        layout?.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)))
        
        let editMenuItem = UIMenuItem(title: NSLocalizedString("Edit", comment: ""),
                                      action: #selector(MessageCollectionViewCell.editMessage(_:)))
        let strikethroughMenuItem = UIMenuItem(title: NSLocalizedString("Strikethrough", comment: ""),
                                      action: #selector(MessageCollectionViewCell.drawStrikethrough(_:)))
        let copyMenuItem = UIMenuItem(title: NSLocalizedString("Copy", comment: ""),
                                      action: #selector(MessageCollectionViewCell.copyMessage(_:)))
        let deleteMenuItem = UIMenuItem(title: NSLocalizedString("Delete", comment: ""),
                                        action: #selector(MessageCollectionViewCell.deleteMessage(_:)))
        UIMenuController.shared.menuItems = [editMenuItem, strikethroughMenuItem, copyMenuItem, deleteMenuItem]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }
    
    func isDateLabelVisible(at indexPath: IndexPath) -> Bool {
        var lastMessageDate = ""
        var thisMessageDate = ""
        
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        
        if indexPath.section > 0, indexPath.section - 1 < savedMessageList.count {
            lastMessageDate = formatter.string(from: savedMessageList[indexPath.section - 1].date)
        }
        
        if indexPath.section < savedMessageList.count {
            thisMessageDate = formatter.string(from: savedMessageList[indexPath.section].date)
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
    
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        switch action {
        case NSSelectorFromString("editMessage:"):
            return savedMessageList[indexPath.section].text != nil
        case NSSelectorFromString("drawStrikethrough:"):
            return savedMessageList[indexPath.section].text != nil
        case NSSelectorFromString("copyMessage:"):
            return true
        case NSSelectorFromString("deleteMessage:"):
            return true
        default:
            return false
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        switch action {
        case NSSelectorFromString("editMessage:"):
            messageInputBar.inputTextView.resignFirstResponder()
//            scrollsToBottomOnKeyboardBeginsEditing = false
//            maintainPositionOnKeyboardFrameChanged = false
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let popupVC = storyboard.instantiateViewController(withIdentifier: "Popup") as! PopupViewController
            popupVC.modalPresentationStyle = .overFullScreen
            popupVC.modalTransitionStyle = .crossDissolve
            popupVC.savedMessage = savedMessageList[indexPath.section]
            present(popupVC, animated: true, completion: nil)
        case NSSelectorFromString("drawStrikethrough:"):
            try! realm.write {
                savedMessageList[indexPath.section].strikethrough = !savedMessageList[indexPath.section].strikethrough
            }
            
            messagesCollectionView.reloadData()
        case NSSelectorFromString("copyMessage:"):
            super.collectionView(collectionView, performAction: action, forItemAt: indexPath, withSender: sender)
        case NSSelectorFromString("deleteMessage:"):
            try! realm.write {
                savedMessageList.remove(at: indexPath.section)
            }
            
            messagesCollectionView.reloadData()
        default:
            break
        }
    }
    
}

extension ChatViewController: IndicatorInfoProvider {
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: currentTab.name)
    }
    
}

extension ChatViewController: MessagesDataSource {
    
    func currentSender() -> SenderType {
        return MockUser(senderId: "", displayName: "")
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
                formatter.setLocalizedDateFormatFromTemplate("MdE")
            default:
                formatter.setLocalizedDateFormatFromTemplate("yMMMdE")
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
        return isDateLabelVisible(at: indexPath) ? 32 : 0
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
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        messageInputBar.inputTextView.resignFirstResponder()
        
        if let collectionView = cell.superview as? UICollectionView {
            if let indexPath = collectionView.indexPath(for: cell) {
                let browser = SKPhotoBrowser(photos: images)
                browser.initializePageIndex(savedMessageList[0..<indexPath.section].compactMap({ $0.image }).count)
                present(browser, animated: true, completion: nil)
            }
        }
    }
    
    func didSelectPhoneNumber(_ phoneNumber: String) {
        guard let phoneNumberURL = URL(string: "tel:\(phoneNumber)") else { return }
        UIApplication.shared.open(phoneNumberURL)
    }
    
    func didSelectURL(_ url: URL) {
        messageInputBar.inputTextView.resignFirstResponder()
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let title = url.scheme == "mailto" ? "New message" : "Open in Safari"
        let urlAction = UIAlertAction(title: NSLocalizedString(title, comment: ""), style: .default) { _ in
            UIApplication.shared.open(url)
            self.becomeFirstResponder()
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
            self.becomeFirstResponder()
        }
        
        alert.addAction(urlAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let components = inputBar.inputTextView.components
        
        for component in components {
            let savedMessage = SavedMessage()
            
            if let text = component as? String {
                savedMessage.text = text
            } else if let image = component as? UIImage {
                savedMessage.image = image.jpegData(compressionQuality: 1.0)
            }
            
            try! realm.write {
                savedMessageList.append(savedMessage)
            }
            
            messagesCollectionView.reloadData()
            messagesCollectionView.scrollToBottom(animated: true)
        }
        
        messageInputBar.inputTextView.text = ""
    }
    
}

extension ChatViewController: CustomMessagesCollectionViewDelegate {
    
    func didTap() {
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
}
