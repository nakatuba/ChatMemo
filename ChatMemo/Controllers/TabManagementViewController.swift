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
    
    let realm = try! Realm()
    var tabResults: Results<Tab>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addButton.layer.cornerRadius = 10.0
        textField.delegate = self
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isEditing = true
        tableView.isScrollEnabled = false
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
    
    @IBAction func didTapRenameButton(_ sender: UIButton) {
        let point = tableView.convert(CGPoint.zero, from: sender)
        guard let indexPath = tableView.indexPathForRow(at: point) else { return }
        guard let tabName = tableView.cellForRow(at: indexPath)?.textLabel?.text else { return }
        
        let alert = UIAlertController(title: String(format: NSLocalizedString("Rename \"%@\"", comment: ""), tabName),
                                      message: nil,
                                      preferredStyle: .alert)
        let changeAction = UIAlertAction(title: NSLocalizedString("Change", comment: ""), style: .default, handler: { _ in
            let textField = alert.textFields![0]
            guard let text = textField.text, !text.isEmpty else { return }
            
            try! self.realm.write {
                self.tabResults[indexPath.row].name = text
            }
            
            self.tableView.reloadData()
            self.loadTableHeight()
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        alert.addTextField(configurationHandler: { textField in
            textField.text = tabName
            textField.placeholder = NSLocalizedString("Please enter a new tab name.", comment: "")
            textField.returnKeyType = .done
        })
        alert.addAction(changeAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func didTapDeleteButton(_ sender: UIButton) {
        let point = tableView.convert(CGPoint.zero, from: sender)
        guard let indexPath = tableView.indexPathForRow(at: point) else { return }
        guard let tabName = tableView.cellForRow(at: indexPath)?.textLabel?.text else { return }
        
        let alert = UIAlertController(title: String(format: NSLocalizedString("Delete \"%@\"", comment: ""), tabName),
                                      message: NSLocalizedString("Are you sure you want to delete this tab?", comment: ""),
                                      preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler: { _ in
            guard let lastIndex = self.tabResults.indices.last else { return }
            
            try! self.realm.write {
                for i in indexPath.row..<lastIndex {
                    self.tabResults[i].name = self.tabResults[i + 1].name
                    self.tabResults[i].savedMessageList.removeAll()
                    for savedMessage in self.tabResults[i + 1].savedMessageList {
                        self.tabResults[i].savedMessageList.append(savedMessage)
                    }
                }
                self.realm.delete(self.tabResults[lastIndex])
            }
            
            self.tableView.reloadData()
            self.loadTableHeight()
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
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
        return tabResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = tabResults[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceTab = tabResults[sourceIndexPath.row]
        
        try! realm.write {
            if sourceIndexPath.row < destinationIndexPath.row {
                // 上から下にセルを移動
                for index in sourceIndexPath.row...destinationIndexPath.row {
                    tabResults[index].order -= 1
                }
            } else {
                // 下から上にセルを移動
                for index in (destinationIndexPath.row...sourceIndexPath.row).reversed() {
                    tabResults[index].order += 1
                }
            }
            
            sourceTab.order = destinationIndexPath.row
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
