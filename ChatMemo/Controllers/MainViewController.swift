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
    
    let realm = try! Realm()
    var tabResults: Results<Tab>!
    
    override func viewDidLoad() {
        tabResults = realm.objects(Tab.self).sorted(byKeyPath: "order")
        
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.buttonBarBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = UIColor(red: 0/255, green: 30/255, blue: 60/255, alpha: 1)
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            oldCell?.label.textColor = .lightGray
            newCell?.label.textColor = UIColor(red: 0/255, green: 30/255, blue: 60/255, alpha: 1)
        }
        
        super.viewDidLoad()
        
        bannerView.adUnitID = "ca-app-pub-1193328696064480/7320727606"
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
    
    override public func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        var viewControllers: [UIViewController] = []
        
        if tabResults.isEmpty {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let emptyVC = storyboard.instantiateViewController(withIdentifier: "Empty")
            view.backgroundColor = emptyVC.view.backgroundColor
            viewControllers.append(emptyVC)
        } else {
            view.backgroundColor = UIColor(red: 120/255, green: 180/255, blue: 240/255, alpha: 1)
            for tab in tabResults {
                let chatVC = ChatViewController()
                chatVC.currentTab = tab
                viewControllers.append(chatVC)
            }
        }
        
        return viewControllers
    }
    
    override func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) {
        super.updateIndicator(for: viewController, fromIndex: fromIndex, toIndex: toIndex, withProgressPercentage: progressPercentage, indexWasChanged: indexWasChanged)
        guard progressPercentage == 1.0 else { return }
        guard let chatVC = children[0] as? ChatViewController else { return }
        chatVC.becomeFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToTabManagement" {
            let tabMagagementVC = segue.destination as! TabManagementViewController
            tabMagagementVC.tabResults = tabResults
        }
    }
    
}
