//
//  LimitedTabViewController.swift
//  TabPageViewController
//
//  Created by Dong Seok Yang on 2016. 7. 27..
//  Copyright © 2016년 CocoaPods. All rights reserved.
//

import UIKit
import TabPageViewController
class LimitedTabViewController: UIViewController {
    var tabItems = [UIViewController]()
    var tabNames = [String]()
    let tabController = TabPageViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        let vc1 = UIViewController()
        vc1.view.backgroundColor = UIColor(red: 251/255, green: 252/255, blue: 149/255, alpha: 1.0)
        let vc2 = UIViewController()
        vc2.view.backgroundColor = UIColor(red: 252/255, green: 120/255, blue: 149/255, alpha: 1.0)
        let vc3 = UIViewController()
        vc3.view.backgroundColor = UIColor(red: 252/255, green: 150/255, blue: 149/255, alpha: 1.0)
        tabItems = [vc1, vc2, vc3]
        tabNames = ["vc1", "vc2", "vc3"]
        tabController.tabItems = tabItems
        tabController.option = setTabPageOption(tabController.tabItems.count)
        tabController.tabViewDataSource = self
        tabController.displayControllerWithIndex(0, direction: .forward, animated: false)
        addChildViewController(tabController)
        self.view.addSubview(tabController.view)

    }

    func setTabPageOption(_ tabItemsCount: Int) -> TabPageOption {
        var option = TabPageOption()
        option.tabHeight = 45
        option.fontSize = 18
        option.tabWidth = view.frame.width / CGFloat(tabItemsCount)
        return option
    }

    @IBAction func loadData() {

    }

}

extension LimitedTabViewController: TabViewDataSource {
    func tabViewItemCount(_ tabView: TabView) -> Int {
        return tabNames.count
    }

    func tabView(_ tabView: TabView, viewForIndexPath index: Int) -> TabTitleViewProtocol {
        let tabTitleLabel = TabTitleLabel()
        tabTitleLabel.text = tabNames[index]
        tabTitleLabel.textAlignment = .center
        return tabTitleLabel
    }
}
