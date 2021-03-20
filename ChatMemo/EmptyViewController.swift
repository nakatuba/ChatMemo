//
//  EmptyViewController.swift
//  ChatMemo
//
//  Created by 中川翼 on 2020/03/06.
//  Copyright © 2020 中川翼. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class EmptyViewController: UIViewController, IndicatorInfoProvider {

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "")
    }

}
