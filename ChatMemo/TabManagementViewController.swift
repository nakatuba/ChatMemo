//
//  TabManagementViewController.swift
//  ChatMemo
//
//  Created by 中川翼 on 2020/02/13.
//  Copyright © 2020 中川翼. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase

class TabManagementViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 30/255, blue: 60/255, alpha: 1)
        addButton.layer.cornerRadius = 10.0
        textField.delegate = self
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isEditing = true
        loadTableHeight()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        view.addGestureRecognizer(tapGesture)
        
        bannerView.adUnitID = "ca-app-pub-1193328696064480/9409287595"
        bannerView.rootViewController = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadBannerAd()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to:size, with:coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.loadBannerAd()
        })
    }
    
    func loadBannerAd() {
        let frame = { () -> CGRect in
            if #available(iOS 11.0, *) {
                return view.frame.inset(by: view.safeAreaInsets)
            } else {
                return view.frame
            }
        }()
        let viewWidth = frame.size.width
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        bannerView.load(GADRequest())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let mainVC = navigationController?.viewControllers[0] as! MainViewController
        mainVC.reloadPagerTabStripView()
    }
    
    @IBAction func didTapAddButton(_ sender: Any) {
        addTab()
    }
    
    @IBAction func didTapChangeButton(_ sender: UIButton) {
        let point = self.tableView.convert(CGPoint.zero, from: sender)
        guard let indexPath = self.tableView.indexPathForRow(at: point) else { return }
        
        let alert = UIAlertController(title: "タブ名変更", message: nil, preferredStyle: .alert)
        let changeAction = UIAlertAction(title: "変更", style: .default, handler: { _ in
            let textField = alert.textFields![0]
            guard let text = textField.text, !text.isEmpty else { return }
            let realm = try! Realm()
            let tabObjects = realm.objects(Tab.self)
            try! realm.write {
                tabObjects[indexPath.row].name = text
            }
            self.tableView.reloadData()
            self.loadTableHeight()
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        alert.addTextField(configurationHandler: { textField in
            let realm = try! Realm()
            let tabObjects = realm.objects(Tab.self)
            textField.text = tabObjects[indexPath.row].name
            textField.placeholder = "新しいタブ名を入力してください"
            textField.returnKeyType = .done
        })
        alert.addAction(changeAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func didTapDeleteButton(_ sender: UIButton) {
        let point = self.tableView.convert(CGPoint.zero, from: sender)
        guard let indexPath = self.tableView.indexPathForRow(at: point) else { return }
        
        let alert = UIAlertController(title: "タブの削除", message: "削除してもいいですか？", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "削除", style: .destructive, handler: { _ in
            let realm = try! Realm()
            let tabObjects = realm.objects(Tab.self)
            guard let lastIndex = tabObjects.indices.last else { return }
            try! realm.write {
                for i in indexPath.row..<lastIndex {
                    tabObjects[i].name = tabObjects[i + 1].name
                    tabObjects[i].savedMessageList.removeAll()
                    for savedMessage in tabObjects[i + 1].savedMessageList {
                        tabObjects[i].savedMessageList.append(savedMessage)
                    }
                }
                realm.delete(tabObjects[lastIndex])
            }
            self.tableView.reloadData()
            self.loadTableHeight()
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer){
        if sender.state == .ended {
            textField.resignFirstResponder()
        }
    }
    
}

extension TabManagementViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addTab()
        return true
    }
    
}

extension TabManagementViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let realm = try! Realm()
        let tabObjects = realm.objects(Tab.self)
        return tabObjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let realm = try! Realm()
        let tabObjects = realm.objects(Tab.self)
        cell.textLabel?.text = tabObjects[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let realm = try! Realm()
        let tabObjects = realm.objects(Tab.self)
        let sourceName = tabObjects[sourceIndexPath.row].name
        let sourceSavedMessageList = List<SavedMessage>()
        
        for savedMessage in  tabObjects[sourceIndexPath.row].savedMessageList {
            sourceSavedMessageList.append(savedMessage)
        }
        
        try! realm.write {
            if sourceIndexPath.row < destinationIndexPath.row {
                for i in sourceIndexPath.row..<destinationIndexPath.row {
                    tabObjects[i].name = tabObjects[i + 1].name
                    tabObjects[i].savedMessageList.removeAll()
                    for savedMessage in tabObjects[i + 1].savedMessageList {
                        tabObjects[i].savedMessageList.append(savedMessage)
                    }
                }
            } else if destinationIndexPath.row < sourceIndexPath.row {
                for i in (destinationIndexPath.row + 1...sourceIndexPath.row).reversed() {
                    tabObjects[i].name = tabObjects[i - 1].name
                    tabObjects[i].savedMessageList.removeAll()
                    for savedMessage in tabObjects[i - 1].savedMessageList {
                        tabObjects[i].savedMessageList.append(savedMessage)
                    }
                }
            }
            tabObjects[destinationIndexPath.row].name = sourceName
            tabObjects[destinationIndexPath.row].savedMessageList.removeAll()
            for savedMessage in sourceSavedMessageList {
                tabObjects[destinationIndexPath.row].savedMessageList.append(savedMessage)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
         return .none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
         return false
    }
    
}

extension TabManagementViewController {
    
    func loadTableHeight() {
        let cellHeight = tableView.cellForRow(at: [0, 0])?.frame.height ?? 0
        let numberOfCell = CGFloat(tableView.numberOfRows(inSection: 0))
        tableHeight.constant = cellHeight * numberOfCell
    }
    
    func addTab() {
        if let text = textField.text, !text.isEmpty {
            let tab = Tab()
            tab.name = text
            let realm = try! Realm()
            try! realm.write {
                realm.add(tab)
            }
            textField.text = ""
            tableView.reloadData()
            loadTableHeight()
        }
        textField.resignFirstResponder()
    }
    
}
