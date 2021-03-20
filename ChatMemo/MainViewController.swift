//
//  MainViewController.swift
//  ChatMemo
//
//  Created by 中川翼 on 2020/02/15.
//  Copyright © 2020 中川翼. All rights reserved.
//

import UIKit
import RealmSwift
import XLPagerTabStrip
import Firebase

class MainViewController: ButtonBarPagerTabStripViewController {

    @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.buttonBarBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = UIColor(red: 0/255, green: 30/255, blue: 60/255, alpha: 1)
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            oldCell?.label.textColor = .lightGray
            newCell?.label.textColor = UIColor(red: 0/255, green: 30/255, blue: 60/255, alpha: 1)
        }
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 30/255, blue: 60/255, alpha: 1)
        
        bannerView.adUnitID = "ca-app-pub-1193328696064480/7320727606"
        bannerView.rootViewController = self
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(view.frame.size.width)
        bannerView.load(GADRequest())
    }
    
    override public func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let realm = try! Realm()
        let tabObjects = realm.objects(Tab.self)
        
        var tab: [UIViewController] = []
        
        if tabObjects.isEmpty {
            view.backgroundColor = .tertiarySystemGroupedBackground
            let emptyVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EmptyViewController")
            tab.append(emptyVC)
        } else {
            view.backgroundColor = UIColor(red: 120/255, green: 180/255, blue: 240/255, alpha: 1)
            for tabObject in tabObjects {
                if let tabIndex = tabObjects.index(of: tabObject) {
                    let chatVC = ChatViewController()
                    chatVC.tabIndex = tabIndex
                    tab.append(chatVC)
                }
            }
        }
                
        return tab
    }

}
