//
//  TabManagementTableViewCell.swift
//  ChatMemo
//
//  Created by 中川翼 on 2020/02/17.
//  Copyright © 2020 中川翼. All rights reserved.
//

import UIKit

class TabManagementTableViewCell: UITableViewCell {
    
    @IBOutlet weak var renameButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        renameButton.layer.borderWidth = 1.0
        renameButton.layer.borderColor = UIColor.systemGreen.cgColor
        renameButton.layer.cornerRadius = 4.0
        renameButton.titleLabel?.adjustsFontSizeToFitWidth = true
        deleteButton.layer.borderWidth = 1.0
        deleteButton.layer.borderColor = UIColor.systemRed.cgColor
        deleteButton.layer.cornerRadius = 4.0
        deleteButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame.size.width -= renameButton.frame.width + deleteButton.frame.width + 20
    }
    
}
