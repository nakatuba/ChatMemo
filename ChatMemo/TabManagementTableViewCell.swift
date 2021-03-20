//
//  TabManagementTableViewCell.swift
//  ChatMemo
//
//  Created by 中川翼 on 2020/02/17.
//  Copyright © 2020 中川翼. All rights reserved.
//

import UIKit

class TabManagementTableViewCell: UITableViewCell {

    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        changeButton.layer.borderWidth = 1.0
        changeButton.layer.borderColor = UIColor.systemGreen.cgColor
        changeButton.layer.cornerRadius = 4.0
        deleteButton.layer.borderWidth = 1.0
        deleteButton.layer.borderColor = UIColor.systemRed.cgColor
        deleteButton.layer.cornerRadius = 4.0
    }

}
