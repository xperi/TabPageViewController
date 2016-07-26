//
//  ViewController.swift
//  TabPageViewController
//
//  Created by EndouMari on 03/19/2016.
//  Copyright (c) 2016 EndouMari. All rights reserved.
//

import UIKit
import TabPageViewController

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func LimitedButton(button: UIButton) {
        let tc = TabPageViewController()
        let vc1 = UIViewController()
        vc1.view.backgroundColor = UIColor(red: 251/255, green: 252/255, blue: 149/255, alpha: 1.0)
        let vc2 = UIViewController()
        vc2.view.backgroundColor = UIColor(red: 252/255, green: 150/255, blue: 149/255, alpha: 1.0)
        let vc3 = UIViewController()
        vc3.view.backgroundColor = UIColor(red: 149/255, green: 218/255, blue: 252/255, alpha: 1.0)
        tc.tabItems = [vc1, vc2]
        tc.displayControllerWithIndex(0, direction: .Forward, animated: false)
        tc.tabViewDataSource = self
        var option = TabPageOption()
        option.tabWidth = view.frame.width / CGFloat(tc.tabItems.count)
        tc.option = option
        navigationController?.pushViewController(tc, animated: true)
    }

    @IBAction func InfinityButton(button: UIButton) {
        let tc = TabPageViewController()
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
        tc.tabItems = [vc1, vc2, vc3, vc4, vc5]
        tc.isInfinity = true
        tc.tabViewDataSource = self
        let nc = UINavigationController()
        nc.viewControllers = [tc]
        var option = TabPageOption()
        tc.option = option
        navigationController?.pushViewController(tc, animated: true)
    }
}
extension ViewController: TabViewDataSource {
    func tabViewItemCount(tabView: TabView) -> Int {
        if !tabView.isInfinity {
            return 2
        }
        return 5
    }

    func tabView(tabView: TabView, viewForIndexPath index: Int) -> TabTitleViewProtocol {
        let tabTitleLabel = TabTitleLabel()
        tabTitleLabel.text = "label\(index)"
        tabTitleLabel.textAlignment = .Center
        return tabTitleLabel
    }
}
