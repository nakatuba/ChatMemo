//
//  SettingsTableViewController.swift
//  ChatMemo
//
//  Created by 中川翼 on 2020/05/20.
//  Copyright © 2020 中川翼. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    let supportArray = [(text: NSLocalizedString("Write a Review", comment: ""),
                         url: "https://itunes.apple.com/app/id1501999625?action=write-review"),
                        (text: NSLocalizedString("Privacy Policy", comment: ""),
                         url: "https://www.nakatuba.com/app-privacy-policy/"),
                        (text: NSLocalizedString("Opinions or Requests", comment: ""),
                         url: "https://tayori.com/form/c5069b2864ba0e350e2a038aaddd08dbc556a381")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isScrollEnabled = false
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("Support", comment: "")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return supportArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = supportArray[indexPath.row].text
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let writeReviewURL = URL(string: supportArray[indexPath.row].url) else { return }
        UIApplication.shared.open(writeReviewURL)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func didTapCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
