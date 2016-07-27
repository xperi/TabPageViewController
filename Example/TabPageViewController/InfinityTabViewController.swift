//
//  InfinityTabViewController.swift
//  TabPageViewController
//
//  Created by Dong Seok Yang on 2016. 7. 27..
//  Copyright © 2016년 CocoaPods. All rights reserved.
//

import UIKit
import TabPageViewController
class InfinityTabViewController: UIViewController {
    var tabItems = [UIViewController]()
    var tabNames = [String]()
    let tabController = TabPageViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
            tabController.tabItems = tabItems
            tabController.tabViewDataSource = self
            tabController.option = setTabPageOption(tabController.tabItems.count)
            tabController.isInfinity = true
            addChildViewController(tabController)
            self.view.addSubview(tabController.view)
    }

    func setTabPageOption(tabItemsCount: Int) -> TabPageOption {
        var option = TabPageOption()
        option.tabHeight = 45
        option.fontSize = 18
        return option
    }

    @IBAction func loadData() {
        tabItems.removeAll()
        tabNames.removeAll()
        let vc1 = UIViewController()
        vc1.view.backgroundColor = UIColor(red: 251/255, green: 252/255, blue: 149/255, alpha: 1.0)
        let vc2 = UIViewController()
        vc2.view.backgroundColor = UIColor(red: 252/255, green: 150/255, blue: 149/255, alpha: 1.0)
        let vc3 = UIViewController()
        vc3.view.backgroundColor = UIColor(red: 149/255, green: 218/255, blue: 252/255, alpha: 1.0)
        let vc4 = UIViewController()
        vc4.view.backgroundColor = UIColor(red: 149/255, green: 252/255, blue: 197/255, alpha: 1.0)
        let vc5 = UIViewController()
        vc5.view.backgroundColor = UIColor(red: 252/255, green: 182/255, blue: 106/255, alpha: 1.0)
        tabItems = [vc1, vc2, vc3, vc4, vc5]
        tabController.tabItems = tabItems
        tabNames = ["vc1", "vc2", "vc3", "vc4", "vc5"]
        tabController.reloadData()
    }

}

extension InfinityTabViewController: TabViewDataSource {
    func tabViewItemCount(tabView: TabView) -> Int {
        return tabNames.count
    }

    func tabView(tabView: TabView, viewForIndexPath index: Int) -> TabTitleViewProtocol {
        let tabTitleLabel = TabTitleLabel()
        tabTitleLabel.text = tabNames[index]
        tabTitleLabel.textAlignment = .Center
        return tabTitleLabel
    }
}
