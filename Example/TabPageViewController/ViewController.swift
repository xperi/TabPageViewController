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
        performSegueWithIdentifier("toLimitedTabViewController", sender: nil)
    }

    @IBAction func InfinityButton(button: UIButton) {
        performSegueWithIdentifier("toInfinityTabViewController", sender: nil)
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
